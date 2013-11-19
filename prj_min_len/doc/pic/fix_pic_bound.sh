#!/bin/bash

fl='pdf_2d_stat_m=17_L=2e+05_F0_F1=1.59e-04.eps'
sed -i '6 s/%%BoundingBox: 50 50 626 482/%%BoundingBox: 110 70 530 430/' $fl
sed -i 's/2252 4540 M/1800 4540 M/' $fl

fl='pdf_2d_stat_fake_m=17_L=2e+05_F0_F1=1.59e-04.eps'
sed -i '6 s/%%BoundingBox: 50 50 626 482/%%BoundingBox: 70 10 600 482/' $fl
sed -i 's/1702 4471 M/1200 4471 M/' $fl

