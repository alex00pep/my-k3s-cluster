#!/bin/bash

docker run -it --entrypoint=/bin/bash --rm -w /workspace -v %cd%:/workspace ansiblecontainer