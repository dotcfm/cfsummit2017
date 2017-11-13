docker ^
  run ^
  -ti ^
  --rm ^
  -p 8500:8500 ^
  -v %cd%\myapp:/opt/coldfusion2016/cfusion/wwwroot/myapp ^
  cfdemo1