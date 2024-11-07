from flask import Flask, render_template, request, make_response, g
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST
from redis import Redis
import os
import socket
import random
import json
import logging

# Environment and configuration setup
option_a = os.getenv('OPTION_A', "Cats")
option_b = os.getenv('OPTION_B', "Dogs")
hostname = socket.gethostname()

app = Flask(__name__)

gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)

# Prometheus metrics
vote_counter = Counter('app_votes_total', 'Total number of votes received', ['option'])
active_sessions = Gauge('app_active_sessions', 'Number of active user sessions')

def get_redis():
    if not hasattr(g, 'redis'):
        g.redis = Redis(host="redis", db=0, socket_timeout=5)
    return g.redis

@app.route("/", methods=['POST','GET'])
def hello():
    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == 'POST':
        redis = get_redis()
        vote = request.form['vote']
        app.logger.info('Received vote for %s', vote)
        data = json.dumps({'voter_id': voter_id, 'vote': vote})
        redis.rpush('votes', data)
        
        # Update Prometheus counter based on the vote
        vote_counter.labels(option=vote).inc()

    resp = make_response(render_template(
        'index.html',
        option_a=option_a,
        option_b=option_b,
        hostname=hostname,
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp

@app.before_request
def before_request():
    # Increase active session count for each request
    active_sessions.inc()

@app.teardown_request
def teardown_request(exception):
    # Decrease active session count when request ends
    active_sessions.dec()

@app.route('/metrics')
def metrics():
    # Expose Prometheus metrics
    return make_response(generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
