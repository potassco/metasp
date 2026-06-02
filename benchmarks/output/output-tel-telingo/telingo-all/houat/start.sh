#!/bin/bash

cd "$(dirname $0)"
sbatch "start0000.dist"
sbatch "start0001.dist"
