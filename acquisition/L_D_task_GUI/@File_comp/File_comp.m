function file = File_comp(varargin)
%    File_comp class constructor.
%   c= File_comp(STATIC_VALUE) creates a  File_comp object which is a
%   Signal component representing the file name containing a pre-synthesized signal.
global FILE_FILE_COMP_DEFAULT BASEDIR_FILE_COMP_DEFAULT
FILE_FILE_COMP_DEFAULT='';
BASEDIR_FILE_COMP_DEFAULT='C:\maestro_results\SoundFiles';

if nargin==0
    file.name='File_comp';
    file.basedir=BASEDIR_FILE_COMP_DEFAULT;
    s_comp=String_comp(FILE_FILE_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Fname');
    s_comp=set(s_comp,'constant_line','Fname/reps:');
    file=class(file,'File_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'File_comp'))
        file = varargin{1};
        if ~isa(file.String_comp,'String_comp')
            s_comp=String_comp(file.String_comp);
            s_comp=set(s_comp,'Input_method_line','Fname:');
            s_comp=set(s_comp,'constant_line','Fname/reps:');
            file.String_comp=s_comp;
        end
    else
        file.name='File_comp';
        file.basedir=BASEDIR_FILE_COMP_DEFAULT;
        s_comp=String_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Fname:');
        s_comp=set(s_comp,'constant_line','Fname/reps:');
        file=class(file,'File_comp',s_comp);
        if ~(is_legal_file(file,varargin{1}))
            treat_error('The file does not exist');
        end
    end

else
    treat_error('Wrong number of input arguments for File_comp');
end