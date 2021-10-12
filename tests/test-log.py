"""Test Pytong."""
import pytest
from pytong import Log, BaseLog


class TestData:
    """Test Data."""

    name: str
    log_root: Log

    def test_log(self):
        """Test Log Class."""
        self.name = "test"
        # create the logger
        self.log_root = Log(name)
        self.log_root.test(log_root.log)


def test_base_log():
    """Test Base Class."""
    base = BaseLog()
