#!/usr/bin/env python3

import datetime
import string
import random
from flask import Flask


application = Flask(__name__)


def _datetime_handler(x):
    if isinstance(x, datetime.datetime):
        return x.isoformat()
    raise TypeError("Unknown type")


@application.route("/")
def hello():
    return "K8s Container stress test"


@application.route("/test")
def test():
    return "K8s Container stress test addition"


@application.route("/health", methods=['GET'])
def _healthcheck():
    return "K8s Stress app is running " + str(datetime.datetime.now()) + "\n"


@application.route("/test/big-response", methods=['GET'])
def big_response():
    N = 1024*1024
    random_string = ''.join(random.choices(string.ascii_uppercase + string.digits, k=N))
    return random_string


if __name__ == '__main__':

    application.run(host='0.0.0.0')
    #application.run(host='0.0.0.0', port=7575, debug=True)
