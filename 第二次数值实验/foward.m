figure('Units', 'centimeter', 'Position', [15 3 20 17], 'name', '向前差分格式'); % 设置图片大小
h = 1/40; t = 1/3200;
Z1 = solve(h, t);
draw(h, t, Z1, 1, "h=1/40, t=1/3200,r=1/2");
h = 1/80; t = 1/12800;
Z2 = solve(h, t);
draw(h, t, Z2, 2, "h=1/80, t=1/12800,r=1/2");
h = 1/80; t = 1/3200;
Z3 = solve(h, t);
Z4 = accurate(h, t); % 调用精确解的函数
draw(h, t, Z4, 3, "精确解");
solution_error(1/40,Z1,1/80,Z4,"h=1/40 t=1/3200");
solution_error(1/80,Z2,1/80,Z4,"h=1/80 t=1/12800");

% 显示震荡
figure('Units', 'centimeter', 'Position', [15 3 20 17], 'name', 'r=2 时震荡情况'); % 设置图片大小
x = 0:h:1;
subplot(2,2,1);
plot(x,Z3(21,:));
title("t=20 数值解");
subplot(2,2,2);
plot(x,Z4(21,:));
title("t=20 精确解");
subplot(2,2,3)
plot(x,Z3(41,:));
title("t=40 数值解");
subplot(2,2,4);
plot(x,Z4(41,:));
title("t=40 精确解")

% 对给定的网格进行迭代求解
function u = solve(h, t)
    n = 1 / h - 1; % 待计算的点数: 由于已有第二类边界, 采用最简单的差分格式, 因此只需求解内点, 共 N - 1 个点
    T = 1 / t; % 迭代的时间层数: T = 0 时已知无需迭代求解
    r = t / (h^2); % 网格比

    % 生成系数矩阵, 显格式
    E = (1 - 2 * r) * speye(n);
    S = sparse(2:n, 1:n - 1, r, n, n);
    A = E + S' + S; % 系数矩阵
    A(1, 1) = 1 - r; % 已知第二类边界条件, 因此需对系数矩阵进行修正
    A(n, n) = 1 - r;

    x = 0:h:1; % 网格化区间
    Z = zeros(T + 1, n + 2); % 构成二维曲面, 包括初始以及边界的二维曲面, 先分配所需的空间, 可以提升速度

    % 初值条件
    u_old = cos(pi * x)';
    Z(1, :) = u_old; % 把初值赋值给第一个时间层
    u_old = u_old(2:n + 1); % 只计算内点, 因此可把边界点略去

    % 迭代数值解
    for i = 2:T + 1
        u_new = A * u_old + t * sin((i - 2) * t); % 前向差分时, 右端时间与已知层时间相同
        Z(i, :) = [u_new(1); u_new; u_new(n)]; % 根据第二类边界条件, 边界处的值等于 x 方向相邻点的数值
        u_old = u_new; % 用当前解出的去迭代下一层时间的
    end

    u = Z; % 返回计算出的数值解, 用于绘图以及计算误差
end