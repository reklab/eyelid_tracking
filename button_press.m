function [frms] = button_press()

% This function holds the scene, until a specific button is pressed.

while true
    w = waitforbuttonpress;
    switch w
        case 1 % (keyboard press)
            key = get(gcf,'currentcharacter');
            switch key
                case 50 % 49 is '2'
                    disp('Skipping 2 frame')
                    frms = 2;
                    break
                case 53 % 53 is '5'
                    disp('Skipping 5 frames')
                    frms = 5;
                    break % break out of the while loop
                otherwise
                    disp('Please try hitting either 2 or 5.') 
                    % Wait for a different command.
            end
    end
end