#!/bin/bash
cd ${BUILD_WORKING_DIRECTORY} && bundle install --path=/tmp/kubevirt_gems && bundle exec rake
