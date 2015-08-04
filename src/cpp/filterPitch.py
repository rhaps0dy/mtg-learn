# -*- coding: utf-8 -*-
#Python code based on filter_pitch.mat by Sergio Giraldo.

#A function that quantices pitch according to the midi number notes. The input P is the midi number with decimal factors calculated by hz2midi function. It filters notes below 55hz (33 midi number), and notes shorter than w frames)


__author__ = 'Sergio Giraldo. MTG 2015'

# P : vector con los pitch
# w : minima longitud de una nota (30ms) 0.03

# framesize usado : 2048
# hopsize usado : 128

# cuando hay poca energia cogelo con silencio

def filter_1(P,w):
    import numpy as np
    import matplotlib.pyplot as plt

    gap =1 #silence gap equal to one frame The idea is that notes and silences must be treated differently: their respective minimun duration is different
    Q=P

    if w!=0:
        #filter short notes =< w frames
        Qdiff=np.append(np.diff(Q),0)#differentiate to find onsets (diff>0) and offsets (diff<0)
        on_off_idx=np.nonzero(Qdiff)[0]#find onset offset index for each note
        note_len=np.diff(on_off_idx)#find the length of each note

        for i in range(len(note_len)):#search notes shorter than w
            cond1=all([Q[on_off_idx[i]+1]>0 , note_len[i]<=w])#if is a note and length is less than w .....OR
            cond2=all([Q[on_off_idx[i]+1]<=0, note_len[i]<=gap])# if is a silence and length is less than gap
            if any([cond1,cond2]):

                prev_int=Q[on_off_idx[i]+1] - Q[on_off_idx[i]]#actual minus previous inteval

                # calculate interval to the next note
                next_note_len=note_len[i]#actual note length
                j=i#next note length
                next_int=Q[on_off_idx[i]+next_note_len+1] - Q[on_off_idx[i]+note_len[i]]
            
                ## CASE 1
                #print i
                if prev_int==-next_int:
                    #the note its a mistake, so the note is the previous(equal to next)
                    Q[on_off_idx[i]+1:on_off_idx[i]+1+note_len[i]]=Q[on_off_idx[i]]
                else:##Calcualte new next interval based on next note length
                    if j!=len(note_len)-1:
                        while note_len[j+1]<w and Q[on_off_idx[j+1]+1]>0:#if next note is too short and is not a rest
                            next_note_len=next_note_len+note_len[j+1]#add next note length to current note
                            j=j+1

                            if len(note_len)-1==j:#if j has reached the end of note length array
                                break

                    next_int=Q[on_off_idx[i]+next_note_len+1]-Q[on_off_idx[i]+note_len[i]]
                
                    ## CASE 2
                    #if the note is right in the middle betwen two notes half of the note is asigne to the previous note and half to the next note(ceil and floor are used in case the length of the note is odd
                    if prev_int==next_int:
                        whb=np.floor(next_note_len/2)#half part that goes backward
                        Q[on_off_idx[i]+1:on_off_idx[i]+whb]=Q[on_off_idx[i]]
                        whf=np.floor(next_note_len/2)#half part that goes foward
                        Q[on_off_idx[i]+whb+1:on_off_idx[i]+whb+whf]=Q[on_off_idx[i]+whf+whb+1]
                    else:# the note is assigned to the closest note
                    
                        ## CASE 3
                        if min(abs(prev_int),abs(next_int))==abs(prev_int):#if the shorter interval is with the previous note
                            Q[on_off_idx[i]+1:on_off_idx[i]+1+note_len[i]]=Q[on_off_idx[i]]#assign the prevoious note
                        else:#assign the next note (no if required)
                            Q[on_off_idx[i]+1:on_off_idx[i]+1+note_len[i]]=Q[on_off_idx[i]+next_note_len+1]#assign the next note


    return Q[:]






                                                                
                                                            
