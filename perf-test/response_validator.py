import requests
import sys
from concurrent.futures import ThreadPoolExecutor

TEST_CONTENT_LENGTH = 1024*1024
endpoint = "http://k8s-test-app.url.com"
NUMBER_OF_TESTS = 1000
MAX_POOL_WORKERS = 32


def test_big_response(i):
    data = requests.get(endpoint + "/test/big-response")

    return data.status_code == 200 \
        and len(data.content) == TEST_CONTENT_LENGTH


def main():
    pool = ThreadPoolExecutor(max_workers=MAX_POOL_WORKERS)
    results = pool.map(test_big_response, list(range(0, NUMBER_OF_TESTS)))
    number_of_tests_passed = 0
    for i in results:
        if i:
            number_of_tests_passed += 1
    print("% tests passed: {}%".format(number_of_tests_passed / NUMBER_OF_TESTS * 100))


if __name__ == '__main__':
    main()
