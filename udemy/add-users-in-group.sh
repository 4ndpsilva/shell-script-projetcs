#!/bin/bash

groupadd dev
for USER in bob tina bia zaira; do adduser -G dev $USER; done