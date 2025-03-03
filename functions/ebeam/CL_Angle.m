function CL_Angle(op, exc_CL, bem, ene2, enei2, BEM_op, d_range1, detQ, detRad, d_angle1, vel)
    %[ psurf, pbulk ] = deal( zeros( numel( imp ), numel( enei ) )); %  Surface/bulk loss matrix init
    %CL_sca=deal( zeros( numel( 1:20:181 ), numel( enei ), 3 )); %  CL spectra matrix init
    multiWaitbar( 'CL angle', 0, 'Color', 'g', 'CanCancel', 'on' ); %  Loop over wavelengths 
    misc.atomicunits;
    j=1;
    angle_r=180;
    step=4;
    for ang=1:step:angle_r+1
        for ien = 1 : length( enei2 )            
            drawnow() % Reads new inputs
            cancelRun() % Cancel function
            sig = bem \ exc_CL( enei2( ien ) ); %  Surface charges        
            [ psurf( :, ien ), pbulk( :, ien ) ]= exc_CL.loss( sig ); %  EELS losses
            angC=degtorad(angle_r-(ang-1)); % XZ angle in rad
            [spec_ang,~] = detInit(op,BEM_op,d_angle1,d_range1,angC,detQ,detRad);
            ffang=farfield(spec_ang,sig); % Farfield 
            [sca_ang,~] = scattering(ffang); %  Farfield scattering
            CL_sca(j,ien,1)=sca_ang.*fine ^ 2 / ( bohr * hartree * pi * vel )./(2*(pi^2)./enei2(ien)); %  Farfield scattering spectra#
            %-------------------------% p pol
            ffp=ffang;
            ffp.e(:,2)=0; % E field in x direction set to 0
            ffp.h(:,1)=0; % B field in y direction set to 0
            [sca,~]=scattering(ffp); %  Farfield calculation
            CL_sca(j,ien,2)=sca.*fine ^ 2 / ( bohr * hartree * pi * vel )./(2*(pi^2)./enei2(ien)); %  Farfield scattering spectra
            %-------------------------% s pol
            ffs=ffang;
            ffs.e(:,1)=0; % E field in y direction set to 0
            ffs.h(:,2)=0; % B field in x direction set to 0
            [sca,~]=scattering(ffs); %  Farfield calculation
            CL_sca(j,ien,3)=sca.*fine ^ 2 / ( bohr * hartree * pi * vel )./(2*(pi^2)./enei2(ien)); %  Farfield scattering spectra
        end
        j=j+1;
        multiWaitbar( 'CL angle', j / numel( (1:step:angle_r+1)-1 ) );      
    end
    multiWaitbar( 'CloseAll' ); %  Close waitbar  
    f=figure('Position', [100, 100, 600, 800]); 
    subplot(3,1,1);    
    imagesc( ene2, (1:step:angle_r+1)-1, CL_sca(:,:,1) );   
    hold on
    plot( ene2, 0 * ene2 + angle_r/2, 'w--' );
    set( gca, 'YDir', 'norm' );
    colorbar
    xlabel( 'Energy (eV)' );
    ylabel( 'Angle (Degrees)' );
    title( 'CL Angle scan' );
    hold off 
    
    subplot(3,1,2);
    imagesc( ene2, (1:step:angle_r+1)-1, CL_sca(:,:,2) );   
    hold on
    plot( ene2, 0 * ene2 + angle_r/2, 'w--' );
    set( gca, 'YDir', 'norm' );
    colorbar
    xlabel( 'Energy (eV)' );
    ylabel( 'Angle (Degrees)' );
    title( 'CL Angle scan p' );
    
    subplot(3,1,3);
    imagesc( ene2, (1:step:angle_r+1)-1, CL_sca(:,:,3) );   
    hold on
    plot( ene2, 0 * ene2 + angle_r/2, 'w--' );
    set( gca, 'YDir', 'norm' );
    colorbar
    xlabel( 'Energy (eV)' );
    ylabel( 'Angle (Degrees)' );
    title( 'CL Angle scan s' );
    
    saveas(gcf,'data/CLangle.fig')
    saveas(gcf,'data/CLangle.png')
end