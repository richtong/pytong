# Rich Tong's Not-so-Famous Python Utilities

For convenience, some useful utilities because importing Python modules is
pretty unfun and it is easy to just publish them to PyPi and use them
everywhere.

Usage is pretty simple

```python
from pytong import Log, BaseLog  #type: ignore

# then for each class you create have a log member to remember it
# set a log_root which is the top and then on each Class initiation
# instantiate a new class
# if you set this base class you get logging
class <Your Class>(BaseLog)
    # Use the decorator pattern that Keras and other use with chaining
    # so every class has a set_logger method that returns the class
    # this allows constructs like foo.set_logger.next_method...
    # note that we pass the name which is by default __name__
    # which for classes is the class name
    def set_logger(self, name: str = __name__) -> <Your Class>:
      """Set Log.

      Setup the root logger and log
      """
      self.log_root = Log(name)
      self.log = self.log_root.log
      return self

   def <some method>(self, <0ther functions>):
      # a convenience as self.log is a lot of typing
      log = self.log
      log.debug(f'I am here with {log=}')
```

## Log by call tree

The logging module automatically creates loggers and lists logs by the call
stack. It also sends different prefixes for class calls.

## Building

You can install the needed pieces with and then upload to test.pypi.org or
pypi.org

```sh
make pip-install
# edit .envrc with the your API Token for test do not include the pypi- that is
# added in the makefile
make test-pypi
# add the pypi api token without the pypi-
make pypi
```

## Testing

The test scaffolding is not working yet.

## File Layout

We adopt the scheme that seems a little redundent where we have a strudture
that is ./pytong/src/pytong and the tests are in ./pytong/tests.
[Ionel](https://blog.ionelmc.ro/2014/05/25/python-packaging/#the-structure)
explains why this is important. And also
[HYnek](https://hynek.me/articles/testing-packaging/) explains why as well.

The biggest reason for this is that you are forced to install code and can
check for packaging breaks. And you don't want to include test modules with
your source code.
