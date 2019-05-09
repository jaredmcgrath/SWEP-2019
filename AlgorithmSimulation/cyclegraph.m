function [A,L,V,D] = cyclegraph(dim)
  %This function makes a cycle graph using the number of agents in the
    %network. It returns the adjacency matrix, A, the Laplacian matrix, L, the
    %eigenvectors, V, and the eigenvalues, D.
    
    A = zeros(dim);
    
    for i = 1:dim
        for j = 1:dim
            if j == i+1 || i == j+1 || j == i-dim+1 || i == j-dim+1
                A(i,j) = 1;
            elseif j == 1
                A(i,j) = 0;
                %change this to 1 to allow self-loops
            else
                A(i,j) = 0;
            end
        end
    end
    
    D_out = zeros(dim);
    
    for i = 1:dim
        for j = 1:dim
            neighbor(j) = A(i,j);
        end
        diag(i) = sum(neighbor);
        D_out(i,i) = diag(i);
        neighbor = [];
    end
    
    L = D_out - A;
    [V,D] = eig(L);
    
end

