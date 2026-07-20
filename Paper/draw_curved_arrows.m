function draw_curved_arrows(dotSize, dotColor, arrowSizes, arrowColors)
    % Draws four dots and connects them with curved arrows.
    % Inputs:
    %   - dotSize: Scalar, size of the dots.
    %   - dotColor: String or RGB triplet, color of the dots.
    %   - arrowSizes: 1x4 vector, sizes of the arrows linking the dots.
    %   - arrowColors: 4x3 matrix, RGB colors for each arrow.

    % Define the positions of the four dots (square shape)
    positions = [0 0; 1 0; 1 1; 0 1]; 

    % Open a new figure
    figure;
    hold on;
    axis equal;
    xlim([-0.5 1.5]);
    ylim([-0.5 1.5]);

    % Plot the dots
    scatter(positions(:,1), positions(:,2), dotSize, [1:4], 'filled');

    % Define pairs for arrow connections
    connections = [1 2; 2 1; 1 3; 3 1; 1 4; 4 1; 4 2; 2 4; 4 3; 3 4; 2 3; 3 2]; 

    % Generate curved arrows
    for i = 1:size(connections,1)
        % Get start and end points
        startPos = positions(connections(i,1), :);
        endPos = positions(connections(i,2), :);

        % Define control point for curvature (midpoint slightly shifted)
        midPoint = (startPos + endPos) / 2 + [0.1, 0.2]; % Adjust for curvature

        % Generate a smooth curve
        t = linspace(0, 1, 100);
        r = rand();
        xCurve = (1 - t).^2 * startPos(1) + 2 * (1 - t) .* t * midPoint(1) + t.^2 * endPos(1);
        yCurve = (1 - t).^2 * startPos(2) + 2 * (1 - t) .* t * midPoint(2) + t.^2 * endPos(2);

        % Plot the curved arrow
        plot(xCurve(1:90)+r*.1, yCurve(1:90) , 'Color', arrowColors{i}, 'LineWidth', arrowSizes(i));
        
                % Draw the arrowhead
        arrowHeadAngle = atan2(endPos(2) - midPoint(2), endPos(1) - midPoint(1));
        arrowHeadLength = 0.05; % Scale arrowhead size

        % Define arrowhead points
        endPos = [xCurve(90) yCurve(90)];
        arrowX = [endPos(1) - arrowHeadLength * cos(arrowHeadAngle - pi/6), endPos(1), ...
                  endPos(1) - arrowHeadLength * cos(arrowHeadAngle + pi/6)];
        arrowY = [endPos(2) - arrowHeadLength * sin(arrowHeadAngle - pi/6), endPos(2), ...
                  endPos(2) - arrowHeadLength * sin(arrowHeadAngle + pi/6)];

        % Plot the arrowhead
        fill(arrowX, arrowY, arrowColors{i}, 'EdgeColor', 'none');

    end

    % Formatting
    xlabel('X');
    ylabel('Y');
    title('Curved Arrows Between Dots');
    grid on;
    hold off;
end





% function draw_arrows(dotSize, dotColor, arrowSizes)
%     % Draws four dots connected by arrows with customizable properties.
%     % Inputs:
%     %   - dotSize: Scalar, size of the dots.
%     %   - dotColor: String or RGB triplet, color of the dots.
%     %   - arrowSizes: 1x4 vector, sizes of the arrows linking the dots.
% 
%     % Define the positions of the four dots (square shape)
%     positions = [0 0; 1 0; 1 1; 0 1]; 
% 
%     % Open a new figure
%     figure;
%     hold on;
%     axis equal;
%     xlim([-0.5 1.5]);
%     ylim([-0.5 1.5]);
% 
%     % Plot the dots
%     scatter(positions(:,1), positions(:,2), dotSize*100, [1:4], 'filled'); hold on
% 
%     % Define pairs for arrow connections
%     connections = [1 2; 2 1; 1 3; 3 1; 1 4; 4 1; 4 2; 2 4; 4 3; 3 4; 2 3; 3 2]; 
% 
%     % Plot arrows between the dots with specified sizes
%     for i = 1:size(connections,1)
%         % Get start and end points
%         startPos = positions(connections(i,1), :);
%         endPos = positions(connections(i,2), :);
% 
%         % Draw the arrow using quiver
%         quiver(startPos(1)+rand()*.1, startPos(2)+rand()*.1, ...
%                (endPos(1) - startPos(1)), (endPos(2) - startPos(2)), ...
%                0, 'MaxHeadSize', 0.5, 'LineWidth', arrowSizes(i), 'Color', 'k');
%     end
% 
%     % Formatting
%     xlabel('X');
%     ylabel('Y');
%     title('Customizable Dots with Arrows');
%     grid on;
%     hold off;
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
