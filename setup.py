from setuptools import  setup, find_packages

__VERSION__ = file('VERSION').read().strip()

dist_name = "pythonskeleton"

setup(
    name = dist_name,
    version = __VERSION__,
    description = "Python skeleton packaging",
    author = 'Telefonica I+D',
    author_email = 'sergisj@tid.es',
    url = 'http://www.tid.es',
    license = '(C) Telefonica I+D',
    packages = find_packages('src'),
    package_dir = {'': 'src'},
    py_modules = ["main"],
    entry_points = {
        'console_scripts': ['%s= main:main' % dist_name] 
    },
    data_files = [('etc/init.d', ['sbin/%s'% dist_name,
                                   'sbin/%srunner' % dist_name]),
                  ('etc/%s' % dist_name,['conf/%s.conf' % dist_name,
                                         'conf/logging.conf'])]
)

