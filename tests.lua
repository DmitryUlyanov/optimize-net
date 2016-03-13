require 'optimize-nn'

local optest = torch.TestSuite()
local tester = torch.Tester()

local models = require 'models'

local function genericTestForward(model,opts)
  local net, input = models[model](opts)
  net:evaluate()
  local out_orig = net:forward(input):clone()

  local mem1 = usedMemory(net,input)

  optimizeMemory(net, input)

  local out = net:forward(input):clone()
  local mem2 = usedMemory(net,input)
  tester:eq(out_orig, out, 'Outputs differ after optimization of '..model)
  tester:assertle(mem2, mem1, 'Optimized model uses more memory! '..
  'Before: '.. mem1..' bytes, After: '..mem2..' bytes')
  print(mem1,mem2, 1-mem2/mem1)
end

function optest.basic()
  genericTestForward('basic1')
end

function optest.basic_conv()
  genericTestForward('basic2')
end

function optest.alexnet()
  genericTestForward('alexnet')
end

function optest.resnet20()
  local opts = {dataset='cifar10',depth=20}
  genericTestForward('resnet', opts)
end

function optest.resnet32()
  local opts = {dataset='cifar10',depth=32}
  genericTestForward('resnet', opts)
end

function optest.resnet56()
  local opts = {dataset='cifar10',depth=56}
  genericTestForward('resnet', opts)
end

function optest.resnet110()
  local opts = {dataset='cifar10',depth=110}
  genericTestForward('resnet', opts)
end

tester:add(optest)
tester:run()


