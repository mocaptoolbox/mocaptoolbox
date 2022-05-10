function mcdemo
% This function illustrates some of the most important functions
% of the Motion Capture Toolbox.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

p1 = cd; p2 = which('mcdemo'); cd(p2(1:end-9))

a(1)={'EXAMPLE 1: Reading, editing, and visualizing MoCap data'};
a(2)={'EXAMPLE 2: Transforming MoCap data'};
a(3)={'EXAMPLE 3: Kinematic analysis'};
a(4)={'EXAMPLE 4: Time-series analysis'};
a(5)={'EXAMPLE 5. Kinetic analysis'};
a(6)={'EXAMPLE 6: Creating animations 1: basics'};
a(7)={'EXAMPLE 7: Creating animations 2: merging two into one'};
a(8)={'EXAMPLE 8: Creating animations 3: colors and traces'};
a(9)={'EXAMPLE 9: Creating animations 3: perspective projection'};
a(10)={'EXAMPLE 10: Principal Components Analysis of movement'};
a(11)={'EXAMPLE 11: Analyzing Wii data'};
a(12)={' '};
a(13)={'(Press ''0'' to quit Motion Capture Toolbox demos)'};
a(14)={' '};

demo_counter=1;
demonro=demo_counter;

while (demonro ~= 0)
	clc
	disp('=======================================================')
	disp('           MOTION CAPTURE TOOLBOX DEMOS')
	disp('=======================================================')
	pause(.1)

	for i =1:13
		disp(a{i})
	end

	if demo_counter==10
		demonro=1; demo_counter=1;
	end

	t=['Enter example number (or hit ''ENTER'' to go to the EXAMPLE ',num2str(demo_counter),'): '];
	demonro=input(t);
		if isempty(demonro)
			demonro=demo_counter;
		end
			if isfinite(demonro)==1
				if demonro==0
					disp('The demo is over. Thank you for your attention.');
					close all
					cd(p1);
					break
					return
				elseif demonro >= 1 & demonro <= 10
					clc; 
					cmd1=['echo mcdemo',num2str(demonro),' on'];
					eval(cmd1);
					eval(['mcdemo',num2str(demonro),';']);
					demo_counter=demonro+1;
				else
					disp('Please enter a number between 0-10.')
				end
			end
end
