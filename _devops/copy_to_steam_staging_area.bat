@echo off
setlocal

SET SRC=%~1
SET DST="c:\Program Files (x86)\Steam\userdata\68910293\1066780\local\staging_area\pm_better-finance-overview_1"

mkdir %DST%
mkdir %DST%\res

xcopy /E /Y "%SRC%\res" %DST%\res
xcopy /Y "%SRC%\workshop*" %DST%\
xcopy /Y "%SRC%\strings*" %DST%\
xcopy /Y "%SRC%\mod*" %DST%\
xcopy /Y "%SRC%\image*" %DST%\