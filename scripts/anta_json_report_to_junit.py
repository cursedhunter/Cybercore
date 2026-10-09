# Copyright (c) 2025 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.
# Subject to Arista Networks, Inc.'s EULA.
# FOR INTERNAL USE ONLY. NOT FOR DISTRIBUTION.
import argparse
import json
import logging
import sys
from pathlib import Path

from junitparser import Error, Failure, JUnitXml, Skipped, TestCase, TestSuite
from natsort import natsorted

logger = logging.getLogger()


def generate_junit_report(input_path: Path, output_path: Path, fail_if_report_empty: bool = False) -> bool:
    xml = JUnitXml()

    has_errors_or_failures = False

    with open(input_path, mode="r", encoding="utf-8") as fd:
        nrfu_report = json.load(fd)

    if len(nrfu_report) == 0:
        logger.error("No nrfu report found or report is empty")
        return fail_if_report_empty

    test_cases_by_node: dict[str, list[TestCase]] = {}

    for report_idx, report in enumerate(nrfu_report):
        node_name = report["name"]
        test_cases = test_cases_by_node.setdefault(node_name, [])

        test_name = report["test"]
        test_case = TestCase(name=test_name, classname=node_name)
        report_result = report["result"]

        if report_result == "failure" or report_result == "error":
            has_errors_or_failures = True

        if report_result != "success":
            result_cls = {
                "error": Error,
                "skipped": Skipped,
                "failure": Failure,
            }.get(report_result)

            if result_cls is None:
                logger.warning("Test result is unknown. Skipping.")
                continue

            test_case.result = [result_cls(message=message) for message in report["messages"]]

        test_cases.append(test_case)

    test_suites: dict[str, TestSuite] = {}

    for node_name in natsorted(test_cases_by_node):
        test_suite = test_suites.setdefault(node_name, TestSuite(node_name))
        test_suite.add_testcases(test_cases_by_node[node_name])

    # Add suites to JunitXml
    for suite in test_suites.values():
        xml.add_testsuite(suite)

    xml.write(output_path.as_posix(), pretty=True, to_console=output_path.name == "-")

    return has_errors_or_failures


def main():
    parser = argparse.ArgumentParser(description="Translates a json ANTA report to JUnit.")
    parser.add_argument("-i", "--input-path", required=True, type=Path, help="Path to the ANTA report file.")
    parser.add_argument("-o", "--output-path", default=Path("-"), type=Path, help="Output path, stdout if not specified.")
    parser.add_argument("--fail-if-empty", action="store_true", help="Fail if report is empty.")

    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)
    logger.info("input_path: %s", args.input_path)
    logger.info("output_path: %s", args.output_path)
    logger.info("fail_if_empty: %s", args.fail_if_empty)

    has_errors_or_failures = generate_junit_report(args.input_path, args.output_path, fail_if_report_empty=args.fail_if_empty)
    if has_errors_or_failures:
        sys.exit("Report has errors or failures")


if __name__ == "__main__":
    main()
