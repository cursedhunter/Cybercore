import argparse
import sys
from pathlib import Path

from junitparser import TestCase, TestSuite, JUnitXml, Skipped, Error, Failure
import json


def generate_junit_report(input_path: Path, output_path: Path) -> bool:
    xml = JUnitXml()

    has_errors_or_failures = False

    for report_path in sorted(input_path.glob('*.json')):
        test_case_results = {}

        print(f"Processing {report_path}")
        with open(report_path, mode="r", encoding="utf-8") as fd:
            nrfu_report = json.load(fd)

        if len(nrfu_report) == 0:
            continue

        node_name = nrfu_report[0]['name']

        for report_idx, report in enumerate(nrfu_report):
            report_test = report['test']
            test_case = test_case_results.setdefault(report_test, [])

            report_result = report['result']
            if report_result == "success":
                continue

            if report_result == "failure" or report_result == "error":
                has_errors_or_failures = True

            report_message = ','.join(report['messages'])

            result_cls = {
                "error": Error,
                "skipped": Skipped,
                "failure": Failure,
            }.get(report_result)
            test_case.append(result_cls(message=report_message))

        # Add suite to JunitXml
        node_suite = TestSuite(node_name)
        test_cases = []
        n_tests = 0
        for test_name, test_results in test_case_results.items():
            test_case = TestCase(name=test_name, classname=f"{node_name}")
            test_case.result = test_results
            n_tests += len(test_results)
            test_cases.append(test_case)
        node_suite.add_testcases(test_cases)
        xml.add_testsuite(node_suite)

    xml.write(output_path.as_posix(), pretty=True)

    return has_errors_or_failures


def main():
    parser = argparse.ArgumentParser(description="Translates a json ANTA report to JUnit.")
    parser.add_argument("-i", "--input-path", required=True, type=Path, help="Path to the ANTA reports/test_results.")
    parser.add_argument("-o", "--output-path", default=Path("nrfu.xml"), type=Path, help="Path to the output junit report.")

    args = parser.parse_args()

    has_errors_or_failures = generate_junit_report(args.input_path, args.output_path)
    sys.exit(1 if has_errors_or_failures else 0)


if __name__ == "__main__":
    main()
