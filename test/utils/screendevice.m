function tests = screendevice
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  slm = otslm.utils.ScreenDevice(1);
  pattern = otslm.simple.linear(slm.size, 50);
  slm.show(pattern);
  pause(2);
  slm.close(pattern);

end
