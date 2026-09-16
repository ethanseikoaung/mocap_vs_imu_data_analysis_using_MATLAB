function [T_EB, T_BE] = ypr_to_rotation(y, p, r)

% given a [y, p, r] triplet in radians, the functions computes the corresponding
% transformation matrix

% converts values in degrees into values in radians
psi = y;
theta = p;
phi = r;

% computes the rotation matrix as product of rotation wrt local axes (post-multiplication)
T_EB = [cos(psi), -sin(psi), 0;
        sin(psi), cos(psi), 0;
        0, 0, 1];
T_EB = T_EB*[cos(theta), 0, sin(theta);
        0, 1, 0;
        -sin(theta), 0, cos(theta)];
T_EB = T_EB*[1, 0, 0;
        0, cos(phi), -sin(phi);
        0, sin(phi), cos(phi)];
T_BE = T_EB';

end