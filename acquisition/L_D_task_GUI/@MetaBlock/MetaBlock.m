function meta=MetaBlock(varargin)
% MetaBlock class constructor. 
% meta=MetaBlock  constructs a metablock object with default values
% meta=MetaBlock( run_mode)
% run_mode - the run mode of the metablock (PART_RND/SEQ)
% (PART_RND -the next is chosen  randomly and the trials are running sequencialy; 
% SEQ- lines+trials are running sequencly).
    global META_RUN_MODE_NAMES;
    global META_RUN_MODE_DEF;
    
   
    META_RUN_MODE_NAMES={'FULL_RND','EACH_TRIAL_LINE_RND','ONCE_LINE_RND','SEQ'};
    META_RUN_MODE_DEF=META_RUN_MODE_NAMES{1};

    if nargin==0  
        meta.run_mode=META_RUN_MODE_DEF;  
        meta.line_list={};
        meta.num_of_lines=0;
        meta=class(meta,'MetaBlock');
        
    elseif nargin==1
        if (isa(varargin{1},'MetaBlock'))
            meta = varargin{1}; 
        else
            tmp_meta=MetaBlock;
            result=check_meta_params(tmp_meta,'Run_mode',varargin{1});
            if result
                clear tmp_meta;
                meta.run_mode=varargin{1}; 
                meta.line_list={};
                meta.num_of_lines=0;
                meta=class(meta,'MetaBlock');
          else
                treat_error('Wrong number of input arguments for MetaBlock');
            end
        end
    end
	  
