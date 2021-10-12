"""
Test Pytong.

Assumes that you are pip installing, so for development run pip install -e
"""
import sys
print(f"{__name__=} {sys.path=}")
from pytong import Log, BaseLog


# https://docs.pytest.org/en/6.2.x/getting-started.html#create-your-first-test
class TestData(BaseLog):
    """Test Loggging."""

    name: str
    log_root: Log

    def test_log(self):
        """Test Log Class."""
        self.name = "test"
        # create the logger
        self.main_log = Log(self.name)
        assert self.main_log is not None
        self.main_root.test(self.main_root.log)

    def test_base_log(self):
        """Test Log Class."""
        assert 0 == 1
