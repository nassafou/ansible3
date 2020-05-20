#! /usr/bin/python
# -*- coding: utf-8 -*-
# Make coding more python3-ish
from __future__ import (absolute_import, division, print_function)
__metaclass__= type

from ansible.plugins.callback.default import CallbackModule as CallbackModule_default
# This callback inherit from default callback
class CallbackModule(CallbackModule_default):*
    CALLBACK_VERSION = 2.0
    CALLBACK_NAME = 'test'
