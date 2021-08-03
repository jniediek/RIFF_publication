function [nMDPState,=nextStateAction(MDPState,RATState)
nMDPState=MDPState;
if nMDPState.type=='att_play' || nMDPState.type=='reward_play'
    if soundIsPlaying
        return;
    end
    nMDPState.type='check_poke';
end
if RATState.action==0
    if nMDPState.pokeInProgress
        nMDPState.nPoke=nMDPState.nPoke+1;
        nMDPState.pokeInProgress='false';
    end 
    return;
end
if ~nMDPState.pokeInProgress
    if nMDPState.action~=RATState.action
        nMDPState.nPoke=0;
    end
    nMDPState.pokeInProgress='true';
    nMDPState.action=RATState.action;
end
