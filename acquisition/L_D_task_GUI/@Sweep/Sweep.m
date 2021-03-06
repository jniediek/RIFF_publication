function swp = Sweep(varargin)
%   SWEEP class constructor.
%   s=Sweep(SDATA,EDATA,NUM_DATA,REPS,MODE,STEP) creates a 
%   sweep object that generates values in the range (SDATA,EDATA). 
%   The number of values generated is NUM_DATA and each is being 
%   repeated REPS time (the total number of values are num_data*reps). 
%   The values are taken from the specified range according to the 
%   specified MODE (RND,SEC) and STEP (LIN,LOG,1/LIN,1/LOG)

switch nargin
case 0
    swp.sdata=1;
    swp.sdata_formula=num2str(swp.sdata);
    swp.edata=1;
    swp.edata_formula=num2str(swp.edata);
    swp.num_data=1;
    swp.num_data_formula=num2str(swp.num_data);
    swp.reps=1;
    swp.reps_formula=num2str(swp.reps);
    swp.mode='RND';
    swp.step='LIN';
    swp.seq_length=swp.num_data*swp.reps;
    swp=class(swp,'Sweep');
    
case 1   
    if (isa(varargin{1},'Sweep'))
       swp = varargin{1}; 
       else
            error('Input argument is not a SWEEP object');
    end
    
case 6
    %checks that all Sweep input parameters are legal
    result=check_params('Sdata',varargin{1},'Edata',varargin{2},...
        'Num_data',varargin{3},'Reps',varargin{4},'Mode',varargin{5},'Step',varargin{6});
    if result
        swp.sdata=varargin{1};
        swp.sdata_formula=num2str(swp.sdata);
        swp.edata=varargin{2};
        swp.edata_formula=num2str(swp.edata);
        swp.num_data=varargin{3};
        swp.num_data_formula=num2str(swp.num_data);
        swp.reps=varargin{4};
        swp.reps_formula=num2str(swp.reps);
        swp.mode=varargin{5};
        swp.step=varargin{6};
        swp.seq_length=swp.num_data*swp.reps;
        swp=class(swp,'Sweep');
end
otherwise
    error('Wrong number of input arguments for Sweep constructor');
end