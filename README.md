# MATLAB Tools
Miscellaneous tools for MATLAB projects; some to deal with objects and graphic handles in a safer way, others to accomplish complex behaviors missing in MATLAB.

## Prerequisites
* [MATLAB][MATLAB]

Code was last built and tested with
* MATLAB R2018a

## Installation
* Install MATLAB
	* Download library from repository and place the MATLAB folder under Documents folder.
	* Create/modify Documents/MATLAB/startup.m and put `addpath('Tools');`
	
## Usage examples

### Example - Callbacks
```matlab
% Invoke a function/method with arbitrary number of parameters.
Callbacks.invoke({@fprintf, '%s %s\n', 'Hello', 'world'});

% Invoke methods from (potentially disposed) objects.
t = timer('TimerFcn', @(~, ~)disp('Tic'));
Callbacks.invoke(t, 'start');
delete(t);
Callbacks.invoke(t, 'start');
```

### Example - Delayed execution with Scheduler
```matlab
% Print Hello after 1 second.
obj = Scheduler();
obj.delay({@disp, 'Hello'}, 1);
```

### Example - Repeated execution with Scheduler
```matlab
ticker = tic;
obj = Scheduler();
% Print elapsed time every second.
handle = obj.repeat(@()fprintf('Elapsed: %.0fs\n', toc(ticker)), 1);
% Stop process after 5 seconds.
obj.delay({@delete, handle}, 5);
```

### Example - Container
```matlab
% Create an object and change its dynamic properties.
container = Container('field1', 1, 'field2', 1:5);
container.set('greeting', 'Hello');
disp(container.field1);
disp(container.field2);
disp(container.greeting);

% Receive a container with arbitrary data from a MATLAB's event
% Create TestClass.m:
classdef TestClass < handle
	events
		Called;
	end

	methods (Access = private)
		function call(obj)
			obj.notify('Called', Container('Greeting', 'Hello', 'Field2', 2, 'Field3', 1:5));
		end
	end

	methods (Static)
		function test()
			testObject = TestClass();
			addlistener(testObject, 'Called', @(source, event)disp(event.Greeting));
			testObject.call();
		end
	end
end

% Then execute:
TestClass.test();
```

## API Reference
While these libraries acquire a better shape, look at the documentation from within MATLAB: Type help followed by the name of any class (those files copied to Documents/MATLAB). Most classes list methods and properties with links that expand their description. For example type `help Compression`.

## Version History
### 0.1.0
* Initial Release: Library and example code

## License
© 2018 [Leonardo Molina][Leonardo Molina]

This project is licensed under the [GNU GPLv3 License][LICENSE.md].

[Leonardo Molina]: https://github.com/leomol
[MATLAB]: https://www.mathworks.com/downloads/
[LICENSE.md]: LICENSE.md
