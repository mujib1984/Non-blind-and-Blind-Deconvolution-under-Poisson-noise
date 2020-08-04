function [u,H,output] = EM_Blind_Deconv(f,pm)


Mh = pm.Mh;
Nh = pm.Nh;
u = pm.u;
H = pm.H;

output.Err = [];


u_const = ones(size(u));

tstart = tic;
U = u;
for  it = 1:pm.maxit
    
    % ------------update image --------------------
    
    % EM step :
    f1a = u./conv2( u_const,rot90(H,2), 'same');
    
    f1b_1 = conv2(u, H, 'valid');
    f1b_2 = f./max(1e-3,f1b_1);
    f1b = conv2(f1b_2, rot90(H,2), 'full') ;
    f1 = f1a.*f1b; % u_half+k
    
    
    u = f1;
    % ---------------update blur -------------------
    gradk  = zeros(Mh,Nh);
    h1 = H./conv2fft(rot90(u, 2),u_const,'valid');
    h2 = conv2fft(rot90(u, 2), f./max(conv2( u,H, 'valid'),1e-3),'valid');
    H = gradk + h1.*h2;
    
    % Kernel projection
    H = H.*(H>0);
    H = H/sum(H(:));
    
    
    output.cpu(it) = toc(tstart);
    
    % ======= Error curve =================
    err = norm(u(:)-U(:))/norm(U(:));
    output.Err = [output.Err err];
    
    if err <= 1e-4
        break;
    end
    U = u;
    
end





