# Rich Tong's Not-so-Famous Python Utilities

For convenience, some useful utilities because importing Python modules is
pretty unfun and it is easy to just publish them to PyPi and use them
everywhere.

## Version 2 Logging

The previous version 1 logging required complex keeping of log
names with a Log_root. Turns out after much reading this is much simpler
than I thought. The trick is that all that is happening is that
logging has virtual tree based on the name of the logger, so a logger named
`netqr.params` means that in the directory `./netqr/params.py` is where the
module (that is the file) is located. This is kept in a dunder `__name__`

So instead of having to do base names and so forth, you can just calculate log
names based on the __name__ and then add some more information.

The way that this works is that you first create a `logging.yaml` that has the
logging parameters. Then at the top of each file (aka module) you manipulate a
global variable with this to get the current active loggers:

```python
import logging
log = logging.getLogger(__name__)
```

This is the main thing needed because

In most cases though, you will actually be better off just adding different
[format
strings](https://docs.python.org/3/library/logging.html#formatter-objects)
since they have so much more data in them, for example, the name of the
function and then the type s for string, d for digit, etc.

Note that you can also says `10s` which means the first 10 characters of the
string only and it becomes a fixed width field:

| String | Meaning
--- | ---
%{asctime}s | LogRecord creation time
%{filename}s | Current file
%{funcName}s | Current function
%{levelname}s | Logging level (eg DEBUG, INFO)
%{levelno}s | Logging number {eg 1-100}
%{lineno}d | Current line number
%{message}s | Message of log
%{module}s | File without the .py
%{name}s | Name of the logger
%{pathname}s | Full path of file
%{process}d | Process id
%{processName}s | Name of process
%{thread}d | Thread id
%{threadName}s | Thread name

So most of the time you will be fine with this level of detail, the main thing
missing is that for class objects, you are missing some detail, but you know
the file location and the line number.

The second trick is that if you want more logging detail then in a function you
can create a logger by create more dotted names, :

```python
import logging

# this logger will be used for all functions in this module
log = logging.getLogger(__name__)

class new_class():
  def __init__(self):
    # use the class logger for all methods that appends the class type to the
    # current file/module
    self.log = logging.getLogger(__name__ + '.' + type(self).__name__)

  def add():
    # log with the instance name and class type
    self.log("Entering a new method to add to the database")

```

### Version 2 Logging helper function

This is much simpler than version 1 and the only helper needed is to load the
YAML file with the configuration:

```python
import logging
from pytong import config_log

# this is the module wide logging by setting a global variable
log = logging.getLogger(__name__)

# setLog creates a logger named <module path>/<class name>
@setLog
class test:
  def __init__(self):
    # the logger name is '__main__.test'
    self.log(f"In {self=}")

def main():
  config_log()
  # the logger name is '__main__' and funcname will be printed
  log.debug(f"{log=} created")
```

## Version 1 Logging (deprecated)

Usage is pretty simple, we use inheritance to have the right logging compared
with v2 which uses a class decorator.

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
