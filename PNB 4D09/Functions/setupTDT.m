function TDT = setupTDT(circuit)

    TDT = TDTRP(circuit, 'RZ6'); 
    % I don't know but some how I need to manually run these three lines...?
    TDT.halt;
    TDT.load(circuit);
    TDT.run;

end