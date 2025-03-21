      program dvcsll
      implicit none
      Integer*4 ixydata,ipol1,ipol2,npoi,imeth
      real*8 vv2cut,ebeam
      Integer*4 iappr,iborn,uel,hel
      common/iborn/iappr,iborn,uel,hel
      
      ixydata=3  !  1-kinematics from xykin.dat, 2-new as in sub xq2tphiar
      
      ipol1=0    ! initial (ipol1) and final (ipol2) target polarization switch:
      ipol2=0    ! 0-unpolarized, 1-long, 2-trans along x-axis, 3-trans along y-axis
      
      iappr=1   !1-exact (BH only), 2-BMK 
      iborn=1   !1-BH, 2-BH-DVCS int, 3-BH+int
      imeth=-1  !22

      if(iappr.eq.2)then
         uel=1     !  beam polarization switch: uel=1(0) to (not) include unpolarized part
         hel=0     !                            hel=1(0) to (not) include polarized part   
      endif
      
      ebeam=5.75     ! beam energy
      
c        vv2cut=.3d0    ! missing mass cut        
         vv2cut=999999999.3d0    ! no missing mass cut used
     
      call xq2tphiar(ixydata,ipol1,ipol2,vv2cut,ebeam,imeth)
     
      end
    
      subroutine xq2tphiar(ixydata,ipol1,ipol2,vv2cut,ebeam,imeth)
      implicit none
      integer*4 nmax
      parameter(nmax=10000)
      real*8 arx0(nmax),arq20(nmax),art0(nmax),arphi0(nmax),eta    
      real*8 vv2cut,ebeam,x,q2,tpl,phiprotdeg,pi,phi,t,phis
      Integer*4 ixydata,ipol1,ipol2,npoi,ipol,i,imeth
      Real*8 artmp
      common/kinpoi/artmp(7),eta(3),ipol
      integer*4 ntpoi,itkey,ntreg1,ntreg2,ntreg3,nttot,itpoi,nphipoi,nphipoi1,nphipoi2,ipg
      real*8 mp,s,sx,xx,w2,lay,t2lim,t1lim,tsp,tpp,epst 
      Integer*4 iappr,iborn,uel,hel
      common/iborn/iappr,iborn,uel,hel
      character*1 cc1a,cc1b,cc1c
      character*12 cfile
      character*2 cc2a,cc2b,cc2c
      data mp/0.938272d0/
	 
      pi=atan(1d0)*4d0
          
      if(ixydata.eq.1)then      
      open(8,file='xykin.dat')
      do i=1,nmax  
            read(8,*,end=111)x,q2,tpl,phiprotdeg
            phi=phiprotdeg*pi/180.
            t=-tpl
c            write(*,*)x,q2,t,phi
            arx0(i)=x
            arq20(i)=q2
            art0(i)=t
            arphi0(i)=phi
       enddo
111    npoi=i-1  
c       print*,npoi
       endif   
       if(ixydata.eq.2)then      
        x=0.4d0     
        q2=1.8d0
        npoi=0
        ntpoi=4  !  
        itkey=1  !  0 or >10000
        nphipoi=9 
        if(itkey.gt.10000)then
            ntreg1=itkey/10000
            ntreg2=(itkey-ntreg1*10000)/100
            ntreg3=itkey-ntreg1*10000-ntreg2*100
            nttot=ntreg1+ntreg2+ntreg3            
        else
            nttot=ntpoi           
        endif
c        do itpoi=1,nttot
        do itpoi=1,1
c		  print *,itpoi
          if(itkey.eq.1)then
            if(itpoi.eq.1)t=-0.5d0
            if(itpoi.eq.2)t=-1.2d0
            if(itpoi.eq.3)t=-1.5d0
            if(itpoi.eq.4)t=-1.8d0
          else
            s=2.*mp*ebeam
            sx=q2/x
            xx=s-sx
            w2=sx-q2+mp**2
            lay=sx**2+4d0*mp**2*q2
            t2lim=-0.5d0*((sx-q2)*(sx+sqrt(lay))+2d0*mp**2*q2)/w2
            t1lim=-0.5d0*((sx-q2)*(sx-sqrt(lay))+2d0*mp**2*q2)/w2
            tsp=-Q2*xx/(s-q2)
            tpp=-Q2*s/(xx+q2)
            epst=(t1lim-t2lim)/100000.
            if(itkey.eq.0)then
                 if(ntpoi.ne.1)t=t2lim+epst+(t1lim-t2lim-2.*epst)*(itpoi-1)/(ntpoi-1)
                 if(ntpoi.eq.1)t=(t2lim+t1lim)/2
            elseif(itkey.gt.10000)then
                 if(itpoi.le.ntreg1)then
                    epst=(tpp-t2lim)/100000.
                    t=t2lim+epst+(tpp-t2lim-2.*epst)*(itpoi-1)/(ntreg1-1)  
                 elseif(itpoi.le.ntreg1+ntreg2)then
                    epst=(tsp-tpp)/100000.
                    t=tpp+epst+(tsp-tpp-2.*epst)*(itpoi-ntreg1-1)/(ntreg2-1)  
                 else
                    epst=(t1lim-tsp)/100000.
                    t=tsp+epst+(t1lim-tsp-2.*epst)*(itpoi-ntreg1-ntreg2-1)/(ntreg3-1)  
                 endif   
             endif
	      endif	 
          do ipg=1,nphipoi
c			    print *,ipg
               nphipoi1=nphipoi/3
               nphipoi2=nphipoi-2*nphipoi1
               if(ipg.le.nphipoi1)then
                  phi=dble(ipg-1)*0.9*pi/nphipoi1             
               endif  
               if(ipg.gt.nphipoi1.and.ipg.le.nphipoi1+nphipoi2)then
                     phi=0.9*pi+dble(ipg-1-nphipoi1)*(1.1-0.9)*pi/(nphipoi2-1)
               endif  
               if(ipg.gt.nphipoi1+nphipoi2)then
                     phi=1.1*pi+dble(ipg-nphipoi1-nphipoi2)*(2.0-1.1)*pi/nphipoi1             
               endif   
               npoi=npoi+1
               arx0(npoi)=x
               arq20(npoi)=q2
               art0(npoi)=t
               arphi0(npoi)=phi
c			   write(*,*)x,q2,t,phi,npoi
           enddo
         enddo
       endif   
       if(ixydata.eq.3)then      
            x=0.1
            q2=1.
			phiprotdeg=160.
            s=2.*mp*ebeam
            sx=q2/x
            xx=s-sx
            w2=sx-q2+mp**2
            lay=sx**2+4d0*mp**2*q2
            t2lim=-0.5d0*((sx-q2)*(sx+sqrt(lay))+2d0*mp**2*q2)/w2
            t1lim=-0.5d0*((sx-q2)*(sx-sqrt(lay))+2d0*mp**2*q2)/w2
           npoi=0
            do t=t1lim,-0.5,(-0.5-t1lim)/100
			npoi=npoi+1
            arx0(npoi)=x
            arq20(npoi)=q2
            arphi0(npoi)=phiprotdeg*pi/180.
            art0(npoi)=t
			enddo
*			   write(*,*)x,q2,t,phi,npoi,t1lim,-0.5,-(-0.5-t1lim)/100
       endif   
       
      do ipol=ipol1,ipol2
         if(ipol.eq.0)then
           eta(1)=0d0
           eta(2)=0d0
           eta(3)=0d0
         endif
         if(ipol.eq.1)then
           eta(1)=0d0
           eta(2)=0d0
           eta(3)=1d0
         endif
         if(ipol.ge.2)then
           phis=(ipol-2)*pi/2d0
           eta(1)=cos(phis)
           eta(2)=sin(phis)
           eta(3)=0d0
         endif
		 
         write(cc2a,'(i1,i1)')iborn,ipol
         cfile='out'//cc1a//'_BH.dat'
         if(iappr.eq.2)then 
           write(cc1b,'(i1)')uel
           write(cc1c,'(i1)')hel
           cfile='out'//cc2a//'_'//cc1b//cc1c//'.dat'
         endif
         open(61,file=cfile)
         call sub_bh_dvcs(npoi,arx0,arq20,art0,arphi0,ebeam,vv2cut,imeth)
         close(61)

      enddo
          
      end
    
      subroutine sub_bh_dvcs(npoi,arx,arq2,art,arphi,ebeam,vv2cut,imeth)
      implicit none
      real*8 arx,arq2,art,arphi,ebeam,vv2cut
      integer*4 npoi
      dimension arx(npoi),arq2(npoi),art(npoi),arphi(npoi)      
      integer*4 imeth,ipoi
      real*8 alpha,barn,mp,mp2,ml2,ml,pi
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
      real*8 s,q2,t,phi,x,xx,sborn,eta
      integer*4 ipol
      common/kinpoi/s,q2,t,phi,x,xx,sborn,eta(3),ipol
      data alpha/0.729735d-2/,barn/0.389379d9/,ml2/0.261112d-6/,mp/0.938272d0/
 
      ml=sqrt(ml2)
      mp2=mp**2
      pi=atan(1d0)*4d0
        s=2d0*mp*ebeam
      do ipoi=1,npoi
         x=arx(ipoi)
         q2=arq2(ipoi)
         t=art(ipoi)
         phi=arphi(ipoi)

          xx=s-q2/x

c           print*,ipoi,npoi,x,q2,t,phi,s,xx

        call sifo(vv2cut,imeth) 
        
      enddo
      end      

      
      subroutine sifo(vv2cut,imeth)
      implicit none
      real*8 alpha,barn,mp,mp2,ml2,ml,pi
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
      real*8 s,q2,t,phi,x,xx,sborn,eta
      integer*4 ipol,iy
      common/kinpoi/s,q2,t,phi,x,xx,sborn,eta(3),ipol
      real*8 vv2cut,zspeak,zppeak,siborn,sum1,sum2,z1,z2,layz,az,cz,sz,sqdz,cpr,spr,sbr,cphbr,sphbr,xsp,sig0s,sig0p,sirad,sirad_t,siexp,sum1add,sum2add,z1mc,z2mc,lat,lay,sx,etaz(3),z1m,z2m,vacpol
      integer*4 imeth,iaddcontr_s,iaddcontr_p,in,nev
      real*4 urand
      
      call addcon(zspeak,zppeak,iaddcontr_s,iaddcontr_p,vv2cut,z1m,z2m,z1mc,z2mc,lat,lay,sx)
       
      sborn=siborn(s,q2,x,t,cos(phi),sin(phi),1,ipol,eta) 

      if(imeth.ne.0)then
      iy=12345678
      nev=2**abs(imeth)
      sum1=0d0
      sum2=0d0
c           write(*,*)' sborn= ',sborn
      do in=1,0 !nev
          z1=z1mc+(1d0-1e-16-z1mc)*urand(iy)
        z2=1.d0
        layz=(z1*s-xx/z2)**2+4d0*mp2*z1*q2/z2
        az=-((z1*s-xx/z2)*t+2d0*mp2*(t-z1*q2/z2))/sqrt(lat*layz)
        cz=(sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2)/sqrt(lay*layz)
        sz=2d0*(1d0/z2-z1)*mp*sqrt(q2*(s*xx-mp2*q2))/sqrt(lay*layz)
        sqdz=sqrt(cz**2+sz**2*cos(phi)**2-az**2)
        cpr=(az*cz+sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
            sphbr=spr*sin(phi)/sbr     
            xsp=z1*q2/(z1*z2*s-xx)
            etaz(1)=cz*eta(1)+sz*eta(3)  
            etaz(2)=eta(2)
            etaz(3)=-sz*eta(1)+cz*eta(3)
        xsp=z1*q2/(z1*z2*s-xx)
c        xb1=z1/(1d0/xb-s*(1d0-z1)/Q2)
        sig0s=siborn(z1*s,z1*q2,xsp,t,cphbr,sphbr,1,ipol,etaz)
        sum1add=(1d0-z1mc)*(1d0+z1**2)*(spr/sqdz*(xsp/x)**2*sig0s-sborn)/(1d0-z1)        
        sum1=sum1+sum1add/dble(nev)
c        sig0s=siborn(z1*s,z1*q2,xsp,t,cos(phi),1,ipol)
c      sum1=sum1+(1d0-z1m)/dble(nev)*(1d0+z1**2)*(spr/sqdz*(xsp/x)**2*sig0s-sborn)/(1d0-z1)        

        if(z1.lt.z1m.and.iaddcontr_s.eq.1)then 
        cpr=(az*cz-sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(-sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
        sphbr=spr*sin(phi)/sbr 
        sig0s=siborn(z1*s,z1*q2,xsp,t,cphbr,sphbr,1,ipol,etaz)
        sum1add=(1d0-z1mc)*(1d0+z1**2)*(-spr/sqdz*(xsp/x)**2*sig0s-sborn)/(1d0-z1)        
        sum1=sum1-sum1add/dble(nev)         
        endif
            
        z1=1.d0
        z2=z2mc+(1d0-1e-16-z2mc)*urand(iy)
        layz=(z1*s-xx/z2)**2+4d0*mp2*z1*q2/z2
        az=-((z1*s-xx/z2)*t+2d0*mp2*(t-z1*q2/z2))/sqrt(lat*layz)
        cz=(sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2)/sqrt(lay*layz)
        sz=2d0*(1d0/z2-z1)*mp*sqrt(q2*(s*xx-mp2*q2))/sqrt(lay*layz)
        sqdz=sqrt(cz**2+sz**2*cos(phi)**2-az**2)
        cpr=(az*cz+sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
            sphbr=spr*sin(phi)/sbr 
            etaz(1)=cz*eta(1)+sz*eta(3)  
            etaz(2)=eta(2)
            etaz(3)=-sz*eta(1)+cz*eta(3)
        xsp=z1*q2/(z1*z2*s-xx)
c        xb2=1d0/(1d0/xb-(1d0-z2)*s/Q2)
            sig0p=siborn(s,q2/z2,xsp,t,cphbr,sphbr,1,ipol,etaz)
            sum2add=(1d0-z2mc)*(1d0+z2**2)*(spr/sqdz*(xsp/x)**2*sig0p/z2-sborn)/(1d0-z2)        
        sum2=sum2+sum2add/dble(nev)

        if(z2.lt.z2m.and.iaddcontr_p.eq.1)then 
        cpr=(az*cz-sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(-sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
        sphbr=spr*sin(phi)/sbr 
        sig0p=siborn(s,q2/z2,xsp,t,cphbr,sphbr,1,ipol,etaz)
        sum2add=(1d0-z2mc)*(1d0+z2**2)*(-spr/sqdz*(xsp/x)**2*sig0p/z2-sborn)/(1d0-z2)        
        sum2=sum2-sum2add/dble(nev)         
        endif
c        print *,z1,z2,z1mc,z2mc,sig0s,sig0p,nev
c        stop
      enddo    
     
      sirad= alpha/Pi*vacpol(-t)*sborn
c     &      +alpha/2d0/pi*(log(q2/ml2)-1d0)
     &      +alpha/2d0/pi*(log(q2/ml2)    )
     &          *(sum1+sum2+(z1m*(z1m+2d0)/2d0+z2m*(z2m+2d0)/2d0
     &          +2d0*log(1d0-z1m)+2d0*log(1d0-z2m))*sborn)

          siexp=  exp(alpha/pi*log(q2/ml2)*log((1d0-z1m)*(1d0-z2m)))*sborn   + alpha    /Pi*vacpol(-t)*sborn
c     &      +alpha/2d0/pi*(log(q2/ml2)-1d0)
     &      +alpha/2d0/pi*(log(q2/ml2)    )
     &          *(sum1+sum2+(z1m*(z1m+2d0)/2d0+z2m*(z2m+2d0)/2d0
     &          )*sborn)

      endif
     
      if(imeth.ge.0)then     
           call stest(sum1,sum2,z1m,z2m,zspeak,zppeak,iaddcontr_s,iaddcontr_p,sborn)
          sirad_t= alpha    /Pi*vacpol(-t)*sborn
     &      +alpha/2d0/pi*(log(q2/ml2)    )
     &          *(sum1+sum2+(z1m*(z1m+2d0)/2d0+z2m*(z2m+2d0)/2d0
     &          +2d0*log(1d0-z1m)+2d0*log(1d0-z2m))*sborn)
      endif 

      if(imeth.lt.0)then     
           write(61,'(7g13.5)')x,q2,t,phi,vv2cut,sborn,sirad/sborn*1d2
           write(*,'(3f8.3,f8.1,10g12.4)')x,q2,t,phi*180/pi,vv2cut,sborn,sirad/sborn*1d2,1d0+sirad/sborn,siexp/sborn
      endif
      if(imeth.eq.0)then     
           write(61,'(4f8.3,g11.3,f14.3,6f11.3)')x,q2,t,phi,vv2cut,sborn,sirad_t/sborn*1d2
           write(*,'(3f8.3,f8.1,10g12.4)')x,q2,t,phi*180/pi,vv2cut,sborn,sirad_t/sborn*1d2,1d0+sirad_t/sborn
      endif
      if(imeth.gt.0)then     
           write(61,'(4f8.3,g11.3,f14.3,6f11.3)')x,q2,t,phi,vv2cut,sborn,sirad/sborn*1d2
           write(*,'(3f8.3,f8.1,10g12.4)')x,q2,t,phi*180/pi,vv2cut,sborn,sirad/sborn*1d2,1d0+sirad/sborn,siexp/sborn,sirad_t/sirad
      endif
      end



      subroutine addcon(zspeak,zppeak,iaddcontr_s,iaddcontr_p,vv2cut,z1m,z2m,z1mc,z2mc,lat,lay,sx)
      implicit none
      real*8 sx,z1m,z2m,tsp,tpp,vv2calc,vv2cut,Raa1,Rbb1,Rcc1,Rdd1,z1speak,z2speak,zspeak,Raa2,Rbb2,Rcc2,Rdd2,z1ppeak,z2ppeak,zppeak
      real*8 w2,xi,alt,aly,vv2min_s,vv2max_s,vv2min_p,vv2max_p,vmax,vv2min_z1m,vv2min_z2m,vv2max_z1m,vv2max_z2m,sxt,lay,lat,z1mc,z2mc
      integer*4 iaddcontr_s,iaddcontr_p
      real*8 alpha,barn,mp,mp2,ml2,ml,pi
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
      real*8 s,q2,t,phi,xs,xx,sborn,eta
      integer*4 ipol
      common/kinpoi/s,q2,t,phi,xs,xx,sborn,eta(3),ipol

           sx=s-xx
          w2=sx-q2+mp2
           lay=sx**2+4d0*mp2*q2
         aly=lay
         tsp=-Q2*xx/(s-q2)
         tpp=-Q2*s/(xx+q2)
           sxt=sx+t 
          lat=t*(t-4d0*mp2)
         alt=lat
         xi=sqrt(lat/lay)
      
c	     print *,' tsp, tpp',tsp,tpp
	  
	  
       z1m=(t*xx-2d0*mp2*t+xi*(xx*sx-2d0*mp2*q2))/(t*s-2d0*mp2*q2+xi*(s*sx+2d0*mp2*q2))    
       z2m=(t*xx+2d0*mp2*q2+xi*(xx*sx-2d0*mp2*q2))/(t*s+2d0*mp2*t+xi*(s*sx+2d0*mp2*q2))
     
     
      Raa1 = 4.*mp2*(aly*(mp2*Q2**2+t*S*(S-Q2))+alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Rbb1 = 4.*mp2*(t*aly*(2*mp2*Q2-xx*(2*S-Q2)-t*(Q2-S))-2.*alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Rcc1 = 4.*mp2*(t*aly*(xx**2+t*(-xx+mp2))+alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Rdd1 = 16.*Mp2**2*aly*alt*(aly*(t*Q2-xx*Q2-t*S)**2-4.*Q2*sin(phi)**2*(S*xx-mp2*Q2)*((t+Q2)**2*mp2+t*Sxt*(Sx-Q2)))
      Rcc2 = 4.*mp2*(aly*(mp2*Q2**2+t*xx*(Q2+xx))+alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Rbb2 = 4.*mp2*(t*aly*(2*mp2*Q2-S*(2*xx+Q2)-t*(Q2+xx))-2.*alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Raa2 = 4.*mp2*(t*aly*(S**2+t*(S+mp2))+alt*Q2*sin(phi)**2*(S*xx-mp2*Q2)) 
      Rdd2 = 16.*Mp2**2*aly*alt*(aly*(t*Q2+S*Q2+t*xx)**2-4.*Q2*sin(phi)**2*(S*xx-mp2*Q2)*((t+Q2)**2*mp2+t*Sxt*(Sx-Q2)))
     
       z1speak=(-Rbb1+sqrt(Rdd1))/2./Raa1
       z2speak=(-Rbb1-sqrt(Rdd1))/2./Raa1
       z1ppeak=(-Rbb2+sqrt(Rdd2))/2./Raa2
       z2ppeak=(-Rbb2-sqrt(Rdd2))/2./Raa2
     
      zspeak=max(z1speak,z2speak)
      zppeak=max(z1ppeak,z2ppeak)

      call vv2fromz(zspeak,1d0,vv2min_s,vv2max_s)
      call vv2fromz(z1m,1d0,vv2min_z1m,vv2max_z1m)
      call vv2fromz(1d0,zppeak,vv2min_p,vv2max_p)
      call vv2fromz(1d0,z2m,vv2min_z2m,vv2max_z2m)
     
      vmax=(sqrt(aly*alt)+sx*t)/2d0/mp2-q2+t

      vv2calc=min(vv2cut,vmax)
     
      call z1z2vmax(z1m,z2m,vv2calc)
     
      if(vv2calc.lt.vv2min_s.or.cos(phi).gt.0d0)then
      iaddcontr_s=0
      z1mc=z1m
      else
      iaddcontr_s=1
      z1mc=zspeak
c      z1mc=z1m
      endif
      
      if(vv2calc.lt.vv2min_p.or.cos(phi).gt.0d0)then
      iaddcontr_p=0
      z2mc=z2m
      else
      iaddcontr_p=1
      z2mc=zppeak
c      z2mc=z2m
      endif

       end


    
            subroutine z1z2vmax(z1m,z2m,vv2)
c        implicit real*8 (a-h,o-z)
        implicit none
        real*8 dlamuw,u,w,vv2,z1m,z2m,alpha,barn,mp,mp2,ml2,ml,pi,s,q2,tm,phi,xs,xx,sborn,eta
        real*8 x,t,sx,sxp,amp2,aml2,aly,sxt
        integer*4 ipol
        common/const/alpha,barn,mp,mp2,ml2,ml,pi
        common/kinpoi/s,q2,tm,phi,xs,xx,sborn,eta(3),ipol

        x=xx 
        t=-tm
        sx=s-xx  
        sxt=sx-t
         amp2=mp2
         aml2=ml2
         sxp=s+xx
         aly=sx**2+4d0*amp2*q2
         
        dlamuw=4d0*(S*x*q2-mp2*q2**2-ml2*aly)*((sxt*(sx-q2)-sx*vv2)*t-amp2*((q2-t-vv2)**2+4d0*q2*vv2))
        w=0.5d0*(t+vv2-q2)+sxp/2d0/aly*(sx*(q2+t+vv2)-2d0*t*q2)+sqrt(max(0d0,dlamuw))/aly*cos(phi)
        u=-0.5d0*(t+vv2-q2)+sxp/2d0/aly*(sx*(q2+t+vv2)-2d0*t*q2)+sqrt(max(0d0,dlamuw))/aly*cos(phi)

        z1m=1-vv2/w
        z2m=u/(u+vv2)

c         z1m=0.99d0
c         z2m=0.99d0
        
c        write(*,*)vv2,w,dlamuw,(S*x*q2-amp2*q2**2-aml2*aly),s,x,q2,amp2
c        stop
       
c        write(*,*)' 22',w,u,vv2,4*dlamuw,0.5d0*(t+vv2-q2)
*            if(dlamuw.lt.0d0)write(62,*)vv2,vmax,dlamuw
c            lauw=4d0*q2*w2*(s*xx-mp2*q2-ml2*lay)*(t1lim-t)*(t-t2lim)
c            w0=-0.5d0*(q2+t)+0.5d0*(s+xx)/lay*(sx*(q2-t)+2d0*t*q2)+sqrt(lauw)/lay*cos(phi)    
c        u0=w0+q2+t
        
        end
   
    
      subroutine vv2fromz(z1,z2,vv2min,vv2max)
c            implicit real*8(a-h,k-m,o-z)
            implicit none
            real*8 z1,z2,vv2min,vv2max,alpha,barn,mp,mp2,ml2,ml,pi,s,q2,t,phi,x,xx,sborn,eta
            real*8 sx,lay,lat,layz,az,cz,sz,sqdz,cpr1,cpr2,vv2_1,vv2_2,sqly,sqlt,dz0
            Integer*4 ipol
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
        common/kinpoi/s,q2,t,phi,x,xx,sborn,eta(3),ipol
        
         sx=s-xx
           lay=sx**2+4d0*mp2*q2
         lat=t*(t-4d0*mp2)
         sqlt=sqrt(lat)
         sqly=sqrt(lay)
        layz=(z1*s-xx/z2)**2+4d0*mp2*z1*q2/z2
        az=-((z1*s-xx/z2)*t+2d0*mp2*(t-z1*q2/z2))/sqrt(lat*layz)
        cz=(sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2)/sqrt(lay*layz)
        sz=2d0*(1d0/z2-z1)*mp*sqrt(q2*(s*xx-mp2*q2))/sqrt(lay*layz)
        dz0=cz**2+sz**2*cos(phi)**2-az**2
        if(dz0.lt.-1d-4) stop
        sqdz=sqrt(max(0d0,dz0))
        cpr1=(az*cz+sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        cpr2=(az*cz-sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
     
         VV2_1 = t*Sx/(2.*Mp2)+t-Q2+sqly*sqlt*cpr1/(2.*Mp2)
         VV2_2 = t*Sx/(2.*Mp2)+t-Q2+sqly*sqlt*cpr2/(2.*Mp2)

         vv2min=min(vv2_1,vv2_2)
         vv2max=max(vv2_1,vv2_2)
         
c         write(*,*)' dz0= ',dz0
         
c         write(*,*)z1,z2,sx,s-xx,(z1*s-xx/z2) ! lay,layz,sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2!,az,cz**2+sz**2,cz,sz,cz**2+sz**2*cos(phi)**2-az**2,sqdz,cpr1,cpr2
         
         end


      double precision function siborn(s,q2,x,t,cphi,sphi,ia,ipol,eta)
        implicit none
      real*8 s,q2,x,t,cphi,sphi,vacpol,alphar,alpha,barn,mp2,ml,mp,ml2,pi,f1,f2,u0,w0,tt1,tt2,lauw,lay,xx,sx,sp,w2,tmin,tmax,factorvac
      real*8 tt3,tt4,f3,f4,phis,etak1,etak2,etap2,eta(3),sqly,sqlsxq
        real*8 tt10,tt20,tt30,tt40,tt1m,tt2m,tt3m,tt4m,phiphi
      integer*4 ia,ipol
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
      Integer*4 iappr,iborn,uel,hel
      common/iborn/iappr,iborn,uel,hel

          if(iappr.eq.2)then
            if(sphi.ge.0d0)phiphi=acos(min(1d0,max(-1d0,cphi)))
            if(sphi.lt.0d0)phiphi=2.*pi-acos(min(1d0,max(-1d0,cphi)))
c             write(*,'(4f8.3,3g16.8)')s/2./mp, x, Q2, t, cphi,sphi, pi-phi
            call bmkxsec(3, 3, 1, -1, uel,hel, s/2./mp, x, Q2, t,  pi-phiphi,siborn,eta,ipol,iborn)
            return   
          endif

      sx=q2/x
      xx=s-sx
      sp=s+xx
      w2=sx-q2+mp2
      lay=sx**2+4d0*mp2*q2
        sqly=sqrt(lay)
      tmin=-0.5d0*((sx-q2)*(sx+dsqrt(lay))+2d0*mp2*q2)/w2
      tmax=-0.5d0*((sx-q2)*(sx-dsqrt(lay))+2d0*mp2*q2)/w2
      call sffun(t,f1,f2,f3,f4)
        lauw=4d0*q2*w2*(s*xx-mp2*q2-ml2*lay)*(tmax-t)*(t-tmin)
      w0=-0.5d0*(q2+t)+0.5d0*sp/lay*(sx*(q2-t)+2d0*t*q2)+sqrt(lauw)/lay*cphi    
      u0=w0+q2+t
c    if(ia.eq.1)alphar=alpha    
caku    if(ia.eq.2)alphar=alpha/(1d0-alpha/2d0/pi*vacpol(q2))    
c    if(ia.eq.2)alphar=alpha/(1d0-alpha    /pi*vacpol(q2))    
      if(ia.eq.1)factorvac=1d0    
      if(ia.eq.2)factorvac=1d0/(1d0-alpha/2d0/pi*vacpol(q2))**2    
        if(ipol.eq.0)then
      tt10=2d0*(u0**2+w0**2-2d0*q2*t)/u0/w0
      tt20=0.5d0*mp2*tt10+t*(s**2+xx**2-q2*sx-s*w0-xx*u0)/u0/w0
         TT1m=2.d0*t*(1d0/u0**2+1d0/w0**2)
         TT2m=mp2/2d0*TT1m+(s**2+s*t)/u0**2+(xx**2-xx*t)/W0**2
          tt1=tt10+2d0*ml2*tt1m
          tt2=tt20+2d0*ml2*tt2m
      siborn=-barn*factorvac*alpha**3*q2*(tt1*f1+tt2*f2)/4d0/pi/s**2/x**2/t/sqly    
c     siborn=-barn*alpha**3*q2*(tt1*f1+tt2*f2)/4d0/pi/s**2/x**2/t/sqly    
        endif
        if(ipol.gt.0)then
          sqlsxq=sqrt(S*XX*Q2-mp2*q2**2)
          etak1=-( sqlsxq/sqly*eta(1)+(S*Sx+2d0*mp2*Q2)/(2d0*mp*sqly)*eta(3) )
          etak2=-( sqlsxq/sqly*eta(1)+(xx*Sx-2d0*mp2*Q2)/(2d0*mp*sqly)*eta(3) )
          etap2=-( sqrt(lauw)/(2.*sqlsxq*sqly)*(eta(1)*cphi+eta(2)*sphi)+(-t*Sx+2d0*mp2*(Q2-t))/(2d0*mp*sqly)*eta(3) )
          tt30=4d0*(2d0*xx*(u0-q2)-2d0*s*(w0+q2)+(w0+u0)*(q2-t))*etap2*mp/((t-4d0*mp**2)*u0*w0)
          tt40=-Mp2*TT30+2d0*mp/(u0*w0)*((q2-u0)*(t*etak2+etap2*xx)+(q2+w0)*(t*etak1+etap2*s))
           tt3m=4d0*((2d0*s+t)*(1d0/u0**2+Sx/s/w0**2)+1d0/w0**2*(-q2+1d0/s*(xx**2+(xx-t)**2)))*etap2*mp/(t-4d0*mp**2)
           tt4m=-Mp2*TT3m+2*mp*((sx+t)/s/w0**2*(t*etak2+etap2*xx)-(1d0/u0**2+1d0/w0**2)*(t*etak1+etap2*s))
            tt3=tt30+2d0*ml2*tt3m
            tt4=tt40+2d0*ml2*tt4m
          siborn=-barn*factorvac*alpha**3*Q2/(4*pi*S**2*x**2*t*sqly)*(TT3*F3+TT4*F4)
        endif

         write(62,'(9g11.3)')t,w2,cphi,w0,u0,lauw,lauw/(4*Q2*S**2*Sx**2),siborn
c         write(*,*)' JJJ ',-0.5d0*(q2+t)+0.5d0*sp/lay*(sx*(q2-t)+2d0*t*q2)
c         write(*,*)' KKK ',lauw/(4d0*Q2**2*S**2*Sx**2),tmax
c         write(*,*)' W0 ',w0,u0
c         write(*,*)' f1,f2 ',f1,f2
c         write(*,*)' si0 ',siborn,ia,etak1,etak2,etap2
c         write(*,*)siborn,-barn*factorvac*alpha**3*q2/4d0/pi/s**2/x**2/t/sqly,tt1*f1,tt2*f2,f2*t/4d0
c         stop
      return
      end
     
        subroutine stest(sum1,sum2,z1m,z2m,zspeak,zppeak,iaddcontr_s,iaddcontr_p,sborn)
        implicit none
        external peak,peaknew
        real*8 sum1,sum2,rez1,rez2,rez2n,rez1n,z1m,z2m,zspeak,zppeak,si0,sborn
        real*8 alpha,barn,mp,mp2,ml2,ml,pi,s,q2,t,phi,x,xx,ssborn,eta,rc
         common/const/alpha,barn,mp,mp2,ml2,ml,pi
        common/kinpoi/s,q2,t,phi,x,xx,ssborn,eta(3),ipol
        integer*4 isp,ipol  ,iaddcontr_s,iaddcontr_p
        common/test/isp
         si0=sborn
         isp=1 
         call simpxx(z1m,1d0-1d-7,1000,1d-4,peak,rez1)
           rez1n=0d0
         if(iaddcontr_s.eq.1)call simpxx(zspeak+1d-7,z1m,1000,1d-4,peaknew,rez1n)
c         call simpxx(z1mc,0.991998482d0,10000,1d-12,peak,rez1)
         isp=2 
         call simpxx(z2m,1d0-1d-7,1000,1d-4,peak,rez2)
           rez2n=0d0
         if(iaddcontr_p.eq.1)call simpxx(zppeak+1d-7,z2m,1000,1d-4,peaknew,rez2n)
c         call simpxx(z2mc,0.963736969d0,1000,1d-12,peak,rez2)
c         call simpxx(0.81711592d0,0.963736969d0,1000,1d-12,peak,rez2)
         rez1=rez1+rez1n
         rez2=rez2+rez2n
c         if(abs(sum1/rez1-1d0).gt.1d-2.or.abs(sum2/rez2-1d0).gt.1d-2)write(*,'(6g12.3)')sum1,rez1,sum1/rez1,sum2,rez2,sum2/rez2
c         write(*,'(4h s: ,6g12.3)')zspeak,z1m
c         write(*,'(4h p: ,6g12.3)')zppeak,z2m
c         write(*,'(6g12.3)')sum1,rez1,rez1n,sum1/rez1,sum2,rez2,rez2n,sum2/rez2
         
         rc=+alpha/2d0/pi*(log(q2/ml2)    )*(rez1+rez2)/sborn

         sum1=rez1
         sum2=rez2
         
c         rc=+alpha/2d0/pi*(log(q2/ml2)    )*(rez1     )/sborn
c             write(*,'(6g12.3)')sborn,rc*1d2,alpha/2d0/pi*log(q2/ml2)*(rez2    )/sborn*1d2
c            stop     
        end 

        double precision function peak(z)
        implicit none
        real*8 z,lay,layz,az,cz,sz,sqdz,cpr,spr,sbr,cphbr,sphbr,xsp,sigp,z1,z2,lat
        real*8 siborn,sigsp,s,q2,t,phi,x,xx,sborn,sx,alpha,barn,mp,mp2,ml2,ml,pi,eta,etaz(3)
        integer*4 isp,ipol  
        common/const/alpha,barn,mp,mp2,ml2,ml,pi
        common/kinpoi/s,q2,t,phi,x,xx,sborn,eta(3),ipol
        common/test/isp
         if(isp.eq.1)then
          z1=z
          z2=1d0
         endif
         if(isp.eq.2)then
          z1=1d0
          z2=z
         endif
            sx=s-xx 
         lat=t*(t-4d0*mp2)
            lay=sx**2+4d0*mp2*q2  
        layz=(z1*s-xx/z2)**2+4d0*mp2*z1*q2/z2
        az=-((z1*s-xx/z2)*t+2d0*mp2*(t-z1*q2/z2))/sqrt(lat*layz)
        cz=(sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2)/sqrt(lay*layz)
        sz=2d0*(1d0/z2-z1)*mp*sqrt(q2*(s*xx-mp2*q2))/sqrt(lay*layz)
        sqdz=sqrt(cz**2+sz**2*cos(phi)**2-az**2)
        cpr=(az*cz+sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
            sphbr=spr*sin(phi)/sbr 
            etaz(1)=cz*eta(1)+sz*eta(3)  
            etaz(2)=eta(2)
            etaz(3)=-sz*eta(1)+cz*eta(3)
        xsp=z1*q2/(z1*z2*s-xx)
        sigsp=siborn(z1*s,z1*q2/z2,xsp,t,cphbr,sphbr,1,ipol,etaz)
        peak=(1d0+z**2)*(spr/sqdz*(xsp/x)**2*sigsp/z2-sborn)/(1d0-z)    
c        peak=(1d0+z**2)*(spr/sqdz*(xsp/x)**2*sigsp/z2      )/(1d0-z)    
        
*        write(*,*)z1,z2,spr,(-sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        
c        peak=(1d0+z**2)*(                            -sborn)/(1d0-z)    
c       write(*,'(4g12.4)')z,z1,z2,peak
c         stop    
        end

        double precision function peaknew(z)
        implicit none
        real*8 z,lay,layz,az,cz,sz,sqdz,cpr,spr,sbr,cphbr,sphbr,cpr_,spr_,sbr_,cphbr_,sphbr_,xsp,sigp,z1,z2,lat
        real*8 siborn,sigsp,sigsp_,s,q2,t,phi,x,xx,sborn,sx,alpha,barn,mp,mp2,ml2,ml,pi,eta,etaz(3)
        integer*4 isp,ipol  
        common/const/alpha,barn,mp,mp2,ml2,ml,pi
        common/kinpoi/s,q2,t,phi,x,xx,sborn,eta(3),ipol
        common/test/isp
         if(isp.eq.1)then
          z1=z
          z2=1d0
         endif
         if(isp.eq.2)then
          z1=1d0
          z2=z
         endif
            sx=s-xx 
         lat=t*(t-4d0*mp2)
            lay=sx**2+4d0*mp2*q2  
        layz=(z1*s-xx/z2)**2+4d0*mp2*z1*q2/z2
        az=-((z1*s-xx/z2)*t+2d0*mp2*(t-z1*q2/z2))/sqrt(lat*layz)
        cz=(sx*(z1*s-xx/z2)+2d0*(1d0/z2+z1)*mp2*q2)/sqrt(lay*layz)
        sz=2d0*(1d0/z2-z1)*mp*sqrt(q2*(s*xx-mp2*q2))/sqrt(lay*layz)
        sqdz=sqrt(cz**2+sz**2*cos(phi)**2-az**2)
        cpr=(az*cz+sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr=(sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr=sqrt(1d0-(cpr*cz-spr*sz*cos(phi))**2)    
        cphbr=(cz*spr*cos(phi)+sz*cpr)/sbr
            sphbr=spr*sin(phi)/sbr 
        cpr_=(az*cz-sqdz*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        spr_=(-sqdz*cz-az*sz*cos(phi))/(cz**2+sz**2*cos(phi)**2)
        sbr_=sqrt(1d0-(cpr_*cz-spr_*sz*cos(phi))**2)    
        cphbr_=(cz*spr_*cos(phi)+sz*cpr_)/sbr_
            sphbr_=spr_*sin(phi)/sbr_ 
            etaz(1)=cz*eta(1)+sz*eta(3)  
            etaz(2)=eta(2)
            etaz(3)=-sz*eta(1)+cz*eta(3)
        xsp=z1*q2/(z1*z2*s-xx)
        sigsp=siborn(z1*s,z1*q2/z2,xsp,t,cphbr,sphbr,1,ipol,etaz)
        sigsp_=siborn(z1*s,z1*q2/z2,xsp,t,cphbr_,sphbr_,1,ipol,etaz)
        peaknew=(1d0+z**2)*(spr/sqdz*(xsp/x)**2*sigsp/z2+spr_/sqdz*(xsp/x)**2*sigsp_/z2)/(1d0-z)    
        
c        write(*,*)z1,z2,spr,spr_!,sbr,sbr_,sigsp,sigsp_
        
c        peak=(1d0+z**2)*(spr/sqdz*(xsp/x)**2*sigsp/z2      )/(1d0-z)    
        
    
        
c        peak=(1d0+z**2)*(                            -sborn)/(1d0-z)    
c        write(*,'(4g12.4)')z,z1,z2,peak
c         stop    
        end

        
        
****************** vacpol *************************************

      double precision function vacpol(t)
c contribution from vacuum polarization by leptons (suml) and hadrons (sumh)
      implicit real*8(a-h,l,m,o-z)
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
c      common/cmp/pi,alpha,amp,amp2,aml,aml2,barn
c      include 'const.inc'
      dimension am2(3)
c
c    am2 : squared masses of charge leptons
c
      data am2/.26110d-6,.111637d-1,3.18301d0/

      suml=0.
      do 10 i=1,3
      a2=2.*am2(i)
      sqlmi=dsqrt(t*t+2.*a2*t)
      allmi=dlog((sqlmi+t)/(sqlmi-t))/sqlmi
  10  suml=suml+2.*(t+a2)*allmi/3.-10./9.+4.*a2*(1.-a2*allmi)/3./t
      if(t.lt.1.d0)then
      aaa = -1.345d-9
      bbb = -2.302d-3
      ccc = 4.091
      elseif(t.lt.64d0)then
      aaa = -1.512d-3
      bbb =  -2.822d-3
      ccc = 1.218
      else
      aaa = -1.1344d-3
      bbb = -3.0680d-3
      ccc = 9.9992d-1
      endif
      sumh = -(aaa+bbb*log(1.+ccc*t)) *2*pi/alpha

      vacpol=suml+sumh
c        vacpol=0.

      end

      subroutine sffun(t,f1,f2,f3,f4)
      implicit real*8(a-h,l,m,o-z)
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
c       call ffpro(-t,fd,fp)
       call nuclff(t,fd,fp)
       f1=(fd+fp)**2
       f2=4d0/t*(fd**2-t*fp**2/4d0/mp2)
       f3=f1
       f4=4d0/t*(Fd+Fp)*(Fd+t/(4*mp2)*Fp)
c      write(*,*)' ff',fd,fp,f1,f2
      end

       subroutine ffpro(t,fd,fp)

      implicit real*8(a-h,l,m,o-z)
      common/const/alpha,barn,mp,mp2,ml2,ml,pi
      gep=1.2742/(1.+t/0.6394**2)-.2742/(1.+t/1.582**2)
      gmp=(1.3262/(1.+t/0.6397**2)-.3262/(1.+t/1.3137**2))*2.7921
c     gep=1./((1.+.61*t)*(1.+2.31*t)*(1.+.04*t))
c     gmp=amm*gep
      tap=t/4d0/mp2
      fd=(gep+tap*gmp)/(1d0+tap)
      fp=(gmp-gep)/(1d0+tap)
 
      end

      subroutine nuclFF( del2,fd,fp )
      implicit double precision (A-H,k,l,m,O-Z)
      parameter (Mv = 0.843D0, kp = 1.79285D0, kn = -1.91D0, mp=0.938272d0)
C
      dipol = 1D0/(1D0 - del2/Mv**2)**2
*
      GE_p = dipol
      GE_n = 0D0
      GM_p = (1D0 + kp)*dipol
      GM_n =        kn*dipol
*
      delm = del2/(2D0*Mp)**2
*
      Fd = (GE_p - delm*GM_p)/(1D0-delm)
      Fp = (GM_p - GE_p)/(1D0-delm)         
c        write(*,*)' ttf',fd,fp 
c      F1pn(2) = (GE_n - delm*GM_n)/(1D0-delm)
c      F2pn(2) = (GM_n - GE_n)/(1D0-delm)         
      return
      end

      
C        Ich  -  positron(electron) = +1(-1)
C int   hel  -  lepton beam polarization
C int   help -  target polarization
C double  dsigma   d^5\sig / dx dQ^2 d|\Delta^2| d\phi_e d\phi_\gamma
C                  (pb GeV^{-4})
c
      subroutine bmkxsec(Ivar, IGPD, Ipn, Ich, uel, hel,   
c     &                 E, xb, Q2, del2, Phi_e, Phi_g,dsigma)
     &                 E, xb, Q2, del2, Phi_g,dsigma,eta,ipol,iborn)
        include "dvcsmom.inc"
c      double precision E, xb, Q2, del2,Phi_e,Phi_g,Phi_s,Phi_gb,dsigma
      double precision E, xb, Q2, del2,Phi_g,Phi_gb,dsigma
      double precision nu,W2,W,qmod,E1cm,P1cm,E2cm,P2cm,del2max,del2min
      double precision Mp, mele, pi
      real*8 alpha000,barn000,mp000,mp2000,ml2000,ml000,pi000
      common/const/alpha000,barn000,mp000,mp2000,ml2000,ml000,pi000
      common/myconst/ Mp, mele, pi
c      data Mp/0.938D0/, mele/0.000511D0/, pi/3.1415926536D0/
      integer istat,Ivar, IGPD, Ipn, Ich, hel, uel
         integer*4 ipol
         real*8 eta(3)
      
      pi=pi000
      mele=ml000
      mp=mp000
c
c
      istat=0                    ! kinematic range OK
      xmin1 = Q2/(2D0*Mp*E)
      xmax1 = 1D0
      nu  = Q2/(2D0*Mp*xb)
      W2  = Mp**2 + 2D0*Mp*nu - Q2
      W   = sqrt(W2)
      qmod = sqrt(nu**2 + Q2)
c
      E1cm = Mp*(Mp + nu)/W
      P1cm = Mp*qmod/W
      E2cm = (W2 + Mp**2)/(2D0*W)
      P2cm = (W2 - Mp**2)/(2D0*W)
      del2max = 2D0*(Mp**2 - E1cm*E2cm - P1cm*P2cm)
      del2min = 2D0*(Mp**2 - E1cm*E2cm + P1cm*P2cm)
c
      if( xb.le.xmin1 .or. xb.gt.xmax1 ) istat=1           !    x  out of range
      if( del2.ge.del2min .or. del2.le.del2max ) istat=2   ! delta out of range

      if (istat.eq.0) then
      call resetmom()
!      call getphoton(E,  xb,  Q2,  del2,  Phi_e,Phi_g)
      call getphoton(E,  xb,  Q2,  del2,  Phi_g)
      Phi_gb=pi - Phi_g
c      Phi_s=Phi_e
c      call bhdvcs(Ivar,IGPD,Ipn,E,  xb,  Q2,  del2,  Phi_s,Phi_gb) 
      call bhdvcs(Ivar,IGPD,Ipn,E,  xb,  Q2,  del2, Phi_gb) 
c
c      dsBH =hc0BH +hc1BH*cos(Phi_gb)+hc2BH*cos(2D0*Phi_gb)
c      dsBHlp =hel*help*(hc0BHlp +hc1BHlp*cos(Phi_gb))
c      dsBHtp =hel*help*cos(Phi_s)*(hc0BHtpcos +hc1BHtpcos*cos(Phi_gb)) 
c     6       +hel*hs1BHtpsin*sin(Phi_s)*sin(Phi_gb)
c      dsDVCS=hc0dvcs+hc1dvcs*cos(Phi_gb)+hs1dvcs*sin(Phi_gb)+hs2dvcs*sin(2*Phi_gb)
c      dsIunp=hc0Iunp +hel*hs1Iunp*sin(Phi_gb)+hc1Iunp*cos(Phi_gb) 
c     6     +hel*hs2Iunp*sin(2*Phi_gb)+hc2Iunp*cos(2*Phi_gb)
c      dsIlp=hel*help*hc0Ilp+hel*help*hc1Ilp*cos(Phi_gb)+help*hs1Ilp*sin(Phi_gb)
c      dsItp=hel*hc0Itpcos*cos(Phi_s)+hc0Itpsin*sin(Phi_s)
c     6     +hc1Itpsin*cos(Phi_gb)*sin(Phi_s)+hel*hc1Itpcos*cos(Phi_gb)*cos(Phi_s)
c     6     +hel*hs1Itpsin*sin(Phi_gb)*sin(Phi_s)+hs1Itpcos*sin(Phi_gb)*cos(Phi_s)


       cosphis=eta(1)*cos(Phi_gb)+eta(2)*sin(Phi_gb)
       sinphis=eta(2)*cos(Phi_gb)-eta(1)*sin(Phi_gb)
       eta3bmk=-eta(3)

      dsBH =uel*(hc0BH +hc1BH*cos(Phi_gb)+hc2BH*cos(2D0*Phi_gb))
      dsBHlp =hel*eta3bmk*(hc0BHlp +hc1BHlp*cos(Phi_gb))
      dsBHtp =hel*cosphis*(hc0BHtpcos +hc1BHtpcos*cos(Phi_gb)) 
     6       +hel*sinphis*hs1BHtpsin*sin(Phi_gb)
c      dsDVCS=hc0dvcs+hc1dvcs*cos(Phi_gb)+hs1dvcs*sin(Phi_gb)+hs2dvcs*sin(2*Phi_gb)
      dsIunp=uel*hc0Iunp +hel*hs1Iunp*sin(Phi_gb)+uel*hc1Iunp*cos(Phi_gb) 
     6     +hel*hs2Iunp*sin(2*Phi_gb)+uel*hc2Iunp*cos(2*Phi_gb)
      dsIlp=eta3bmk*(hel*hc0Ilp+hel*hc1Ilp*cos(Phi_gb)+uel*hs1Ilp*sin(Phi_gb))
      dsItp=hel*hc0Itpcos*cosphis+uel*hc0Itpsin*sinphis
     6     +uel*hc1Itpsin*cos(Phi_gb)*sinphis+hel*hc1Itpcos*cos(Phi_gb)*cosphis
     6     +hel*hs1Itpsin*sin(Phi_gb)*sinphis+uel*hs1Itpcos*sin(Phi_gb)*cosphis

*	     write(61,'(8g11.3)')phi_gb,hc0Iunp,hc1Iunp,hc2Iunp,hs1Iunp,hs2Iunp
c	     write(*,'(8g11.3)')xb,q2,del2,Phi_g ,hc0Iunp,hs1Iunp,hc1Iunp,hs2Iunp,hc2Iunp
c		 stop

	 
c      
CC       dsigma=dsBH +dsDVCS-Ich*dsIunp !+dsBHlp -Ich*dsIlp !-Ich*dsItp

      if(iborn.eq.1.and.ipol.eq.0) dsigma=2.*pi*dsBH
      if(iborn.eq.1.and.ipol.gt.0) dsigma=2.*pi*(dsBHlp + dsBHtp)
      if(iborn.eq.2.and.ipol.eq.0) dsigma=2.*pi*(-Ich*dsIunp)
      if(iborn.eq.2.and.ipol.gt.0) dsigma=2.*pi*(-Ich*dsIlp-Ich*dsItp)
      if(iborn.eq.3.and.ipol.eq.0) dsigma=2.*pi*(dsBH-Ich*dsIunp)
      if(iborn.eq.3.and.ipol.gt.0) dsigma=2.*pi*(dsBHlp + dsBHtp-Ich*dsIlp-Ich*dsItp)

c      write(*,*)dsigma,eta(1),eta(2),eta(3),dsBHlp,dsBHtp,cos(Phi_gb),sin(Phi_gb)
c      stop

cc       dsigma=2.*pi*dsBH !+dsDVCS-Ich*dsIunp !+dsBHlp -Ich*dsIlp !-Ich*dsItp
c       dsigma=2.*pi*dsIunp
c      dsigma=2.*pi*dsBH
       
c       write(*,'(6f8.3,g16.5)')E, xb, Q2, del2, Phi_e, Phi_g,dsigma


c       write(*,11) dsBH,hc0BH,hc1BH,cos(Phi_gb),hc2BH,cos(2D0*Phi_gb)
!xb,del2,Phi_g ,hc0BH,hc1BH/hc0BH,hc0BHlp/hc0BH,hc1BHlp/hc0BH,dsIunp
 11   format(3h+++ ,15G11.3)
      else
       dsigma=0
c      print *,'out of limits ',xb,xmin1,xmax1,del2,del2min,del2max,istat      
      endif
      return
      end
c
c      subroutine bhdvcs(Ivar,IGPD,Ipn,Ed, xbd, Q2d, del2d, phield, phigd)
      subroutine bhdvcs(Ivar,IGPD,Ipn,Ed, xbd, Q2d, del2d,  phigd)
c
C BH+DVCS+INT by V. Korotkov
C Tpol and Lpol added by  H.Avakian
c
C   Diff. cross-section for Bethe-Heitler, DVCS and interf.term 
C
C         d^5\sig / dx dQ^2 d|\Delta^2| d\phi_e d\phi_\gamma
C              (pb GeV^{-4})
C INPUT:
C        Ivar -  1 (BH only), 2 (DVCS + int only), 3 (BH + DVCS + int)
C        IGPD -  GPD variant
C        Ipn  -  proton(neutron) target = 1(2)
C real   E(GeV), xb, Q2(GeV^2), del2(GeV^2)(negative) 
C real   phiel(rad) - scatt. electron azimuthal angle
C real   phig(rad)  - photon azimuthal angle around momentum transfer vector q
C OUTPUT:
C real   hs*,hc* sin and cos moments of 5-fold diff. cross-section for
C                            BH, DVCS and interf. terms
*
      implicit double precision (A-H,O-Z)
       include "dvcsmom.inc"

      parameter ( alpha = 1D0/137.036D0, hc2  = 0.38938D0)
      parameter ( coeff = 1D+9*hc2*alpha**3 )
c
      double precision Mp, mele, pi
      common/myconst/ Mp, mele, pi
*
      double precision nu, k1pl, k2pl, Kfac, Jfac
c      common/todvcs/ xb, yb, Q2, del2, del2min,phip,phipel,P1,P2,Kfac,ds
      common/todvcs/ xb, yb, Q2, del2, del2min,phip,P1,P2,Kfac,ds
*
      common/formfac/ F1pn(2), F2pn(2)
*
      xb    = xbd
      Q2    = Q2d
      del2  = del2d
*
      nu  = Q2d/(2D0*Mp*xbd)
      qmod = sqrt(nu**2 + Q2d)
      yb = nu/Ed
      Esc = Ed - nu

c
      eps = 2D0*xbd*Mp/sqrt(Q2)
      eps2=eps*eps
      qeps2=1D0 + eps2
      sqeps2=sqrt(qeps2)
      ds = coeff*(xbd*yb**2/(16D0*pi**2*Q2**2))/sqeps2
c
      del2min=-Q2*(2D0*(1D0-xb)*(1D0-sqeps2)+eps2)
      del2min=del2min/(4D0*xb*(1D0-xb)+eps2)
      tau  = del2d/(4D0*Mp**2)
      taum1=1D0-tau
      xtau=xbd*xbd/tau
      del2q2=del2d/Q2
      del2q4=del2q2*del2q2
      del2q2m1=1D0-del2q2
*
*
      phip = phigd 
c      phipel = phield 
*
      call nuclFF00( del2d )
*
      y1eps=1D0 - yb - yb*yb*eps2/4D0
      sqy1eps=sqrt(y1eps)
      Kfac = sqrt((-del2q2)*(1D0 - xbd)*y1eps*
     *       (1D0 - del2min/del2d)*(sqrt(1D0 + eps2) + 
     *  ((4D0*xbd*(1D0 - xbd) + eps2)/(4D0*(1D0 - xbd)))*
     *                                       ((del2d - del2min)/Q2)))
      Jfac = (1D0 - yb - yb*eps2/2D0)*(1D0 + del2q2) - 
     *       (1D0 - xbd)*(2D0 - yb)*del2q2
caku      P1 = -(Jfac + 2D0*Kfac*cos(phip))/(yb*(1D0 + eps2))
      P1 = -(Jfac + 2D0*Kfac*cos(phip))/(yb*(1D0 + eps2))
      P2 = 1D0 + del2q2 - P1

c      write(*,'(10g11.3)')p1,ed,xbd,yb,del2,q2d,phip,nu,kfac,jfac

c
        if( Ivar.eq.1 .or. Ivar.eq.3 ) then   
       F1 = F1pn(Ipn)
       F2 = F2pn(Ipn)    
       F1_M_F = F1 + tau*F2
       F1_M_F2 = F1**2 - tau*F2**2
       F1_P_F = F1 + F2
       F1_P_F2 = F1_P_F*F1_P_F
       c01_BH = 8D0*Kfac**2*((2D0 + 3D0*eps2)*Q2*F1_M_F2/del2d +
     *                                          2D0*xbd**2*F1_P_F2)
       c02_BH = (2D0 - yb)**2*((2D0 + eps2)*F1_M_F2*
     *       ((2D0*xbd*Mp)**2*(1D0 + del2q2)**2/del2d + 
     *                         4D0*(1D0 - xbd)*(1D0 + xbd*del2q2)) +
     *     4D0*xbd**2*F1_P_F2*(xbd + 
     *                   (1D0 - xbd + eps2/2D0)*(del2q2m1)**2 -
     *                    xbd*(1D0 - 2D0*xbd)*(del2q2)**2))
       c03_BH = 8D0*(1D0 + eps2)*(1D0 - yb - yb*yb*eps2/4D0)*
     *       (2D0*eps2*(1D0 - del2d/(4D0*Mp**2))*F1_M_F2 - 
     *           xbd**2*(del2q2m1)**2*F1_P_F2)
       c0_BH = c01_BH + c02_BH + c03_BH
       c1_BH = 8D0*Kfac*(2D0 - yb)*(
     *      F1_M_F2*(4D0*(xbd*Mp)**2/del2d - 2D0*xbd - eps2) +
     *      F1_P_F2*2D0*xbd**2*(1D0 - (1D0 - 2D0*xbd)*del2q2))
       c2_BH = 8D0*(xbd*Kfac)**2*(F1_M_F2*4D0*Mp**2/del2d + 2D0*F1_P_F2)
c
c     BH-lpol part
c
      bhkin1=8D0*xbd*yb*sqeps2/taum1*F1_P_F
      c01_BHlp=(xbd/2D0*del2q2m1-tau)/2D0
      c02_BHlp=2D0-xbd-2D0*(1D0-xbd)**2*del2q2+eps2*del2q2m1
     6         -xbd*(1D0-2D0*xbd)*del2q4
      c03_BHlp=1D0-(1D0-xbd)*del2q2
      c04_BHlp=xtau/4D0*(1D0+del2q2)**2+(1D0-xbd)*(1D0+xbd*del2q2)
      c0_BHlp=c01_BHlp*c02_BHlp*F1_P_F+c03_BHlp*c04_BHlp*F1_M_F
      c0_BHlp=c0_BHlp*(2D0-yb)*bhkin1
c
caku      c11_BHlp=2D0*tau-xbd*del2q2m1*(1D0-xbd+xbd*del2q2)
      c11_BHlp=(2D0*tau-xbd*del2q2m1)*(1D0-xbd+xbd*del2q2)
caku      c12_BHlp=1D0+xbd-(3D0-2D0*xbd)*(1D0+xbd*del2q2)-xtau*(1D0-del2q4)
      c12_BHlp=1D0+xbd-(3D0-2D0*xbd)*(1D0+xbd*del2q2)-xtau*(1D0+del2q4)
      c1_BHlp=c11_BHlp*F1_P_F+c12_BHlp*F1_M_F
      c1_BHlp=-c1_BHlp*Kfac*bhkin1
c
c
c     BH-Tpol part
c
      c01_BHtpcos=-8D0*(2D0-yb)*yb*sqrt(q2d)/Mp*sqeps2*Kfac/sqy1eps
c
      c02_BHtpcos=xbd*(xbd*Mp)**2/q2d*del2q2m1*F1_P_F
      c03_BHtpcos=1D0-(1D0-xbd)*del2q2
      c04_BHtpcos=xtau/4D0*del2q2m1*F1+xbd/2D0*F2
      c0_BHtpcos=c01_BHtpcos*F1_P_F*(c02_BHtpcos+c03_BHtpcos*c04_BHtpcos)
c
      c11_BHtpcos=-16D0*xbd*yb*sqy1eps*Mp/sqrt(q2d)
      c11_BHtpcos= c11_BHtpcos*sqeps2*F1_P_F
      c12_BHtpcos=2D0*Kfac*Kfac*q2d/del2/y1eps
      c13_BHtpcos=xbd*del2q2m1*F1+tau*F2
      c14_BHtpcos=qeps2*xbd*del2q2m1*F1_M_F
      c1_BHtpcos=c11_BHtpcos*(c12_BHtpcos*c13_BHtpcos+c14_BHtpcos)
c
      s11_BHtpsin=16D0*yb*xbd*xbd*sqy1eps/sqrt(q2d)*Mp
      s12_BHtpsin=qeps2*sqeps2*del2q2m1*F1_P_F*F1_M_F
      s1_BHtpsin=s11_BHtpsin*s12_BHtpsin
c
       BHfact=ds/((xbd*yb*(1D0 + eps2))**2*del2d*P1*P2)
ccc       BHfact=ds/((xbd*yb*(1D0 + eps2))**2*del2d)
       hc0BH=c0_BH*BHfact
       hc1BH=c1_BH*BHfact
       hc2BH=c2_BH*BHfact

caku       write(*,11)BHfact,Jfac, 2D0*Kfac*cos(phip),EPS2,c0_BH,c1_BH,c2_BH
 11   format(3h++1 ,15G11.3)
c
       hc0BHlp=c0_BHlp*BHfact
       hc1BHlp=c1_BHlp*BHfact
c
       hc0BHtpcos=c0_BHtpcos*BHfact
       hc1BHtpcos=c1_BHtpcos*BHfact
       hs1BHtpsin=s1_BHtpsin*BHfact
c
        endif
c
        if( Ivar.eq.2 .or. Ivar.eq.3 ) then       
         call dvcsfun( IGPD, Ipn)
        endif
c

        
c        write(*,*)hc0BHtpcos/BHfact,hc1BHtpcos/BHfact,hs1BHtpsin/BHfact,f1,f2,kfac
c        stop


      return
      end

      subroutine dvcsfun( IGPD, Ipn)
      implicit double precision (A-H,O-Z)
       include "dvcsmom.inc"
      double precision Kfac,Intfac
c      common/todvcs/ x, y,Q2,del2,del2min,phip,phipel,P1,P2,Kfac,ds
      common/todvcs/ x, y,Q2,del2,del2min,phip,P1,P2,Kfac,ds
      common/formfac/ F1pn(2), F2pn(2)
      double precision Mp, mele, pi
      common/myconst/ Mp, mele, pi
c
      real zskew,zF1,zF2,zHp,zEp,zHtp,zEtp,zCIim
      common /zgpds/zskew,zF1,zF2,zHp,zEp,zHtp,zEtp,zCIim
c
      skew = x/(2D0 - x)
      call amptab( IGPD, Ipn, skew, del2, 
     &             H1_RE, H1_IM, H1T_RE, H1T_IM,
     &             E1_RE, E1_IM, E1T_RE, E1T_IM )
*
c
c
C         proton/neutron
      F1 = F1pn(Ipn)
      F2 = F2pn(Ipn)
c
c
c      print *,skew,F1,F2,del2
      zskew=skew
      zF1=F1
      zF2=F2
      zHp=H1_IM
      zEp=E1_IM
      zHtp=H1T_IM
      zEtp=E1T_IM
c
*
      deldel    = 1D0 - del2min/del2
      deldel_sq = sqrt(deldel)
      del2m2    = -del2/Mp**2
      del2m4    = -del2m2/4D0
      delm2_sq  = sqrt(del2m2)
      cy2   = 2D0 - 2D0*y + y**2
      Intfac=ds/(x*y**3*P1*P2*(-del2))
c
c
C  DVCS
C     
      a1 = H1_RE**2 + H1_IM**2 + H1T_RE**2 + H1T_IM**2
      a2 = 2.*( H1_RE*E1_RE  +  H1_IM*E1_IM +
     &         H1T_RE*E1T_RE + H1T_IM*E1T_IM )
      a3 =  E1_RE**2 +  E1_IM**2
      a4 = E1T_RE**2 + E1T_IM**2 
      C_DVCS = ( 4D0*(1D0-x)*a1 - a2*x**2 - (x**2 + (2D0-x)**2*del2m4)*a3 
     &           - x**2*del2m4*a4 )/(2D0 - x)**2
      C_DVCS_eff = -x*C_DVCS
      c0_DVCS = 2D0*cy2*C_DVCS
      c1_DVCS = 8D0*((2D0 - y)/(2D0 - x))*C_DVCS_eff
      T_DVCS  = (c0_DVCS + Kfac*c1_DVCS*cos(phip))/(y**2*Q2)
      DVCSfac=ds/(y**2*Q2)
      hc0dvcs=c0_DVCS*DVCSfac
      hc1dvcs=Kfac*c1_DVCS*DVCSfac
C
C  INTERF
C
c
c
      C_I_re = F1*H1_RE + x/(2D0-x)*(F1+F2)*H1T_RE - del2m4*F2*E1_RE
      C_I_im1 = F1*H1_IM
      C_I_im2 = x/(2D0-x)*(F1+F2)*H1T_IM
      C_I_im3  = -del2m4*F2*E1_IM
      
      C_I_im = C_I_im1 + C_I_im2 + C_I_im3
      zCIim=-C_I_im/F1 
      RE2    = x/(2D0-x)*(H1_RE + E1_RE) + H1T_RE
      C_I_re_eff = -x*C_I_re
      C_I_im_eff = -x*C_I_im
      b1 = (2D0 - x)*(1D0 - y) 
      b1= b1 + (2D0-y)**2/(1D0-y)*Kfac*Kfac/del2*Q2 ! old - (1D0 - x)*(2D0 - y)**2*deldel
      b2 = (1D0 - y)*x*(F1 + F2)
      c0_I = -8D0*(2D0 - y)*( b1*C_I_re - b2*RE2 )
      c1_I = -8D0*cy2*C_I_re
      s1_I =  8D0*y*(2D0 - y)*C_I_im
      c2_I = -16D0*((2D0 - y)/(2D0 - x))*C_I_re_eff
      s2_I =  16D0*(y/(2D0 - x))*C_I_im_eff
c
      hs2Iunp=Kfac*Kfac*s2_I*Intfac
      hs1Iunp=Kfac*s1_I*Intfac
      hc2Iunp=Kfac*Kfac*c2_I*Intfac
      hc1Iunp=Kfac*c1_I*Intfac
      hc0Iunp=del2/Q2*c0_I*Intfac
c
c      print *, 'vvv ',hs1Iunp/hc0BH,C_I_im2/C_I_im1,C_I_im3/C_I_im1
c
c      print *,'mysl-dvcs',hs1Iunp,hc1Iunp,hc0Iunp
C
C  LPOL
C
      C_LP_re = (F1+F2)*skew*(H1_RE+x/2D0*E1_RE)+
     6          F1*H1T_RE-skew*(x/2D0*F1+del2m4*F2)*E1T_RE
c
c
      C_LP_im = (F1+F2)*skew*(H1_IM+x/2D0*E1_IM)+
     6          F1*H1T_IM-skew*(x/2D0*F1+del2m4*F2)*E1T_IM
c
      DC_LP_re=-skew*(F1+F2)*(H1_RE+x/2D0*E1_RE+skew
     6*(H1T_RE+x/2D0*E1T_RE))
      DC_LP_im=-skew*(F1+F2)*(H1_IM+x/2D0*E1_IM+skew
     6*(H1T_IM+x/2D0*E1T_IM))
c
      yf2=(2D0-y)**2/(1D0-y)+2
      c0lp_I =-8*y*(Kfac**2*yf2*C_LP_re+(1D0-y)*(2D0-x)*del2/Q2
     6        *(DC_LP_re+C_LP_re))
      s1lp_I = 8*Kfac*cy2*C_LP_im
      c1lp_I = -8*Kfac*y*(2D0-y)*C_LP_re

C
C  TPOL
C
      xb2=x*skew
      C_TPP_re_s = (F1+F2)*(xb2*(H1_RE+x/2D0*E1_RE)+x*del2m4*E1_RE)
     6          -xb2*F1*(H1T_RE+x/2D0*E1T_RE)
      C_TPP_re_b1 =del2m4*4D0*(1D0-x)/(2D0-x)*F2*H1T_RE
      C_TPP_re_b21 =-del2m4*x*F1*E1T_RE
      C_TPP_re_b22 =-del2m4*xb2*F2*E1T_RE
      C_TPP_re_b =C_TPP_re_b1+C_TPP_re_b21+C_TPP_re_b22
c
      C_TPP_im_s = (F1+F2)*(xb2*(H1_IM+x/2D0*E1_IM)+x*del2m4*E1_IM)
     6          -xb2*F1*(H1T_IM+x/2D0*E1T_IM)
      C_TPP_im_b =del2m4*(4D0*(1D0-x)/(2D0-x)*F2*H1T_IM
     6            -(x*F1+xb2*F2)*E1T_IM)
c
c
c
      C_TPM_re_s = 1D0/(2D0-x)*(x*x*F1-(1D0-x)*4D0*del2m4*F2)*H1_RE
     6          -xb2*(F1+F2)*(H1T_RE+del2m4*E1T_RE)
      C_TPM_re_b = (del2m4*((2D0-x)*F1+xb2*F2) +xb2*F1)*E1_RE
c
      C_TPM_im_s = 1D0/(2D0-x)*(x*x*F1-(1D0-x)*4D0*del2m4*F2)*H1_IM
     6          -xb2*(F1+F2)*(H1T_IM+del2m4*E1T_IM)
      C_TPM_im_b = (del2m4*((2D0-x)*F1+xb2*F2) +xb2*F1)*E1_IM
c
c
      C_TPM_re=C_TPM_re_s+C_TPM_re_b
      C_TPP_re=C_TPP_re_s+C_TPP_re_b
      C_TPM_im=C_TPM_im_s+C_TPM_im_b
      C_TPP_im=C_TPP_im_s+C_TPP_im_b
c
c
c
      DC_TPP_re=-4D0*del2m4*(F2*H1T_RE-x/(2D0-x)*(F1+x/2D0*F2)*E1T_RE)
      DC_TPM_re=4D0*del2m4*(F2*H1_RE-F1*E1_RE)
c
      DC_TPP_im=-4D0*del2m4*(F2*H1T_IM-x/(2D0-x)*(F1+x/2D0*F2)*E1T_IM)
      DC_TPM_im=4D0*del2m4*(F2*H1_IM-F1*E1_IM)
c
c
c
      qm8=8D0*Mp*sqrt(1D0-y)/sqrt(Q2)
      c0tpcos_I = -qm8*Kfac*y*(((2D0-y)**2/(1D0-y)+2D0)*C_TPP_re+DC_TPP_re)
      c0tpsin_I = qm8*Kfac*(2D0-y)*((2D0-y)**2/(1D0-y)*C_TPM_im+DC_TPM_im)
c
      c1tpcos_I = -qm8*y*(2D0-y)*C_TPP_re
      c1tpsin_I = qm8*cy2*C_TPM_im
c
      s1tpcos_I = qm8*cy2*C_TPP_im
      s1tpsin_I = -qm8*y*(2D0-y)*C_TPM_re

      hc0Itpcos = c0tpcos_I*Intfac
      hc0Itpsin = c0tpsin_I*Intfac
      hc1Itpcos = c1tpcos_I*Intfac
      hc1Itpsin = c1tpsin_I*Intfac
      hs1Itpcos = s1tpcos_I*Intfac
      hs1Itpsin = s1tpsin_I*Intfac
c
c 
      hs1Ilp = s1lp_I*Intfac
      hc1Ilp = c1lp_I*Intfac
      hc0Ilp = c0lp_I*Intfac
c
      return
      end

      subroutine amptab( IGPD, Ipn, skew, del2, 
     &                   H1_RE, H1_IM, H1T_RE, H1T_IM,
     &                   E1_RE, E1_IM, E1T_RE, E1T_IM )
      double precision skew, del2, H1_RE, H1_IM, H1T_RE, H1T_IM,
     &                             E1_RE, E1_IM, E1T_RE, E1T_IM 
      double precision F1pn(2), F2pn(2)
      common/formfac/ F1pn, F2pn
*
      common/retbl/ vh1ure(51,5),  vh1dre(51,5),
     &              vh1ture(51,5), vh1tdre(51,5),
     &              ve1ure(51,5),  ve1dre(51,5),
     &              ve1ture(51,5), ve1tdre(51,5)
      common/imtbl/ vh1uim(51,5),  vh1dim(51,5),
     &              vh1tuim(51,5), vh1tdim(51,5),
     &              ve1uim(51,5),  ve1dim(51,5),
     &              ve1tuim(51,5), ve1tdim(51,5)
*
      common/retbl1/ vh1urenf(51,21,2), vh1drenf(51,21,2) 
      common/imtbl1/ vh1uimnf(51,21,2), vh1dimnf(51,21,2)
*
      double precision Mp, mele, pi
      common/myconst/ Mp, mele, pi
      real mpi/0.1396/
      data init/1/
*
      SAVE
*
      if( init .eq. 1 ) then
        init = 0
        call rtable
        skewmin  = 0.01D0
        skewmax  = 1.00D0
        skewminl = log10(skewmin)
        skewmaxl = log10(skewmax)
        dskewl   = (skewmaxl - skewminl)/51D0
        dlmin    = 0.01D0
        dlmax    = 1.00D0
        dlminl   = log10(dlmin)
        dlmaxl   = log10(dlmax)
        ddll     = (dlmaxl - dlminl)/20D0
      endif
*
      F1u = 2D0*F1pn(1) + F1pn(2)
      F1d = 2D0*F1pn(2) + F1pn(1)
      F2u = 2D0*F2pn(1) + F2pn(2)
      F2d = 2D0*F2pn(2) + F2pn(1)
*
      DS   = (log10(skew) - skewminl)/dskewl + 1
      IS   = int(DS)
      FDS  = DS - real(IS)
      FDS1 = 1. - FDS
*
      DT   = (log10(-del2) - dlminl)/ddll + 1
      IT   = int(DT)
      FDT  = DT - real(IT)
      FDT1 = 1. - FDT
*
      if( IGPD .ge. 6 ) then
        IGPD1 = IGPD - 4
        IGPD2 = IGPD - 5
      else
        IGPD1 = IGPD
      endif
*
        if( IGPD .le. 5 ) then
      h1ure =   vh1ure(IS,IGPD1)*FDS1 + vh1ure(IS+1,IGPD1)*FDS
      h1dre =   vh1dre(IS,IGPD1)*FDS1 + vh1dre(IS+1,IGPD1)*FDS
*
      h1uim =   vh1uim(IS,IGPD1)*FDS1 + vh1uim(IS+1,IGPD1)*FDS
      h1dim =   vh1dim(IS,IGPD1)*FDS1 + vh1dim(IS+1,IGPD1)*FDS
        else
      h1ure = (vh1urenf(IS,IT,IGPD2)*FDS1 + 
     &           vh1urenf(IS+1,IT,IGPD2)*FDS)*FDT1 +
     &        (vh1urenf(IS,IT+1,IGPD2)*FDS1 +
     &           vh1urenf(IS+1,IT+1,IGPD2)*FDS)*FDT
      h1dre = (vh1drenf(IS,IT,IGPD2)*FDS1 + 
     &           vh1drenf(IS+1,IT,IGPD2)*FDS)*FDT1 +
     &        (vh1drenf(IS,IT+1,IGPD2)*FDS1 +
     &           vh1drenf(IS+1,IT+1,IGPD2)*FDS)*FDT
*
      h1uim = (vh1uimnf(IS,IT,IGPD2)*FDS1 + 
     &           vh1uimnf(IS+1,IT,IGPD2)*FDS)*FDT1 +
     &        (vh1uimnf(IS,IT+1,IGPD2)*FDS1 +
     &           vh1uimnf(IS+1,IT+1,IGPD2)*FDS)*FDT
      h1dim = (vh1dimnf(IS,IT,IGPD2)*FDS1 + 
     &           vh1dimnf(IS+1,IT,IGPD2)*FDS)*FDT1 +
     &        (vh1dimnf(IS,IT+1,IGPD2)*FDS1 +
     &           vh1dimnf(IS+1,IT+1,IGPD2)*FDS)*FDT
        endif
*
      h1ture = vh1ture(IS,IGPD1)*FDS1 + vh1ture(IS+1,IGPD1)*FDS
      h1tdre = vh1tdre(IS,IGPD1)*FDS1 + vh1tdre(IS+1,IGPD1)*FDS
*
      e1ure =   ve1ure(IS,IGPD1)*FDS1 + ve1ure(IS+1,IGPD1)*FDS
      e1dre =   ve1dre(IS,IGPD1)*FDS1 + ve1dre(IS+1,IGPD1)*FDS
*
      e1ture = ve1ture(IS,IGPD1)*FDS1 + ve1ture(IS+1,IGPD1)*FDS
      e1tdre = ve1tdre(IS,IGPD1)*FDS1 + ve1tdre(IS+1,IGPD1)*FDS
*
      h1tuim = vh1tuim(IS,IGPD1)*FDS1 + vh1tuim(IS+1,IGPD1)*FDS
      h1tdim = vh1tdim(IS,IGPD1)*FDS1 + vh1tdim(IS+1,IGPD1)*FDS
*
      e1uim =   ve1uim(IS,IGPD1)*FDS1 + ve1uim(IS+1,IGPD1)*FDS
      e1dim =   ve1dim(IS,IGPD1)*FDS1 + ve1dim(IS+1,IGPD1)*FDS
*
      e1tuim = ve1tuim(IS,IGPD1)*FDS1 + ve1tuim(IS+1,IGPD1)*FDS
      e1tdim = ve1tdim(IS,IGPD1)*FDS1 + ve1tdim(IS+1,IGPD1)*FDS
*
      gA  = 1.267D0/(1D0 - del2/0.84D0)**2
      gA0 = 0.6D0*gA
      gAu = 0.5D0*( gA + gA0)/( 0.8D0*1.267D0)
      gAd = 0.5D0*(-gA + gA0)/(-0.2D0*1.267D0)
      ha = 4D0*Mp**2*1.267D0/(mpi**2-del2)
*
        if( Ipn .eq. 1 ) then
          if( IGPD .le. 5 ) then
      H1_RE = (4D0*(F1u/2D0)*h1ure + F1d*h1dre)/9D0
      H1_IM = (4D0*(F1u/2D0)*h1uim + F1d*h1dim)/9D0
          else
      H1_RE = (4D0*h1ure + h1dre)/9D0
      H1_IM = (4D0*h1uim + h1dim)/9D0
          endif
      H1T_RE = (4D0*gAu*h1ture + gAd*h1tdre)/9D0
      H1T_IM = (4D0*gAu*h1tuim + gAd*h1tdim)/9D0
      E1_RE = (4D0*(F2u/2D0)*e1ure + F2d*e1dre)/9D0
      E1_IM = (4D0*(F2u/2D0)*e1uim + F2d*e1dim)/9D0
      E1T_RE = ha*(4D0*e1ture + e1tdre)/9D0
      E1T_IM = ha*(4D0*e1tuim + e1tdim)/9D0
        elseif( Ipn .eq. 2 ) then
      H1_RE = (4D0*(F1d/2D0)*h1dre + F1u*h1ure)/9D0
      H1_IM = (4D0*(F1d/2D0)*h1dim + F1u*h1uim)/9D0
      H1T_RE = (4D0*gAd*h1tdre + gAu*h1ture)/9D0
      H1T_IM = (4D0*gAd*h1tdim + gAu*h1tuim)/9D0
      E1_RE = (4D0*(F2d/2D0)*e1dre + F2u*e1ure)/9D0
      E1_IM = (4D0*(F2d/2D0)*e1dim + F2u*e1uim)/9D0
      E1T_RE = ha*(4D0*e1tdre + e1ture)/9D0
      E1T_IM = ha*(4D0*e1tdim + e1tuim)/9D0
        endif
*
      end

      subroutine rtable
*
*      A - 1, B - 2, C - 3, D - 4, E - 5 
*
      common/retbl/ vh1ure(51,5),  vh1dre(51,5),
     &              vh1ture(51,5), vh1tdre(51,5),
     &              ve1ure(51,5),  ve1dre(51,5),
     &              ve1ture(51,5), ve1tdre(51,5)
      common/imtbl/ vh1uim(51,5),  vh1dim(51,5),
     &              vh1tuim(51,5), vh1tdim(51,5),
     &              ve1uim(51,5),  ve1dim(51,5),
     &              ve1tuim(51,5), ve1tdim(51,5)
*
*         6, 7
*
      common/retbl1/ vh1urenf(51,21,2), vh1drenf(51,21,2) 
      common/imtbl1/ vh1uimnf(51,21,2), vh1dimnf(51,21,2)
* 
      open(unit=11,file='gpd.dat',status='old')
      do i = 1,51
        read(11,101) vh1ure(i,1),vh1dre(i,1),vh1ture(i,1),vh1tdre(i,1),
     &               ve1ture(i,1),ve1tdre(i,1) 
      enddo
      call ucopy(vh1ure(1,1),ve1ure(1,1),51)
      call ucopy(vh1dre(1,1),ve1dre(1,1),51)
      do j=2,5
        call ucopy(ve1ture(1,1),ve1ture(1,j),51)
        call ucopy(ve1tdre(1,1),ve1tdre(1,j),51)       
      enddo
*
      do j = 2,3
       do i = 1,51
        read(11,102) vh1ure(i,j),vh1dre(i,j),vh1ture(i,j),vh1tdre(i,j)
       enddo
      enddo
      call ucopy(vh1ure(1,2),ve1ure(1,2),102)
      call ucopy(vh1dre(1,2),ve1dre(1,2),102)
*
      do j = 4,5
       do i = 1,51
        read(11,101) vh1ure(i,j),vh1dre(i,j),vh1ture(i,j),vh1tdre(i,j),
     &               ve1ure(i,j),ve1dre(i,j)
       enddo
      enddo
*
      do i = 1,51
        read(11,101) vh1uim(i,1),vh1dim(i,1),vh1tuim(i,1),vh1tdim(i,1),
     &               ve1tuim(i,1),ve1tdim(i,1) 
      enddo
      call ucopy(vh1uim(1,1),ve1uim(1,1),51)
      call ucopy(vh1dim(1,1),ve1dim(1,1),51)
      do j=2,5
        call ucopy(ve1tuim(1,1),ve1tuim(1,j),51)
        call ucopy(ve1tdim(1,1),ve1tdim(1,j),51)       
      enddo
*
      do j = 2,3
       do i = 1,51
        read(11,102) vh1uim(i,j),vh1dim(i,j),vh1tuim(i,j),vh1tdim(i,j)
       enddo
      enddo
      call ucopy(vh1uim(1,2),ve1uim(1,2),102)
      call ucopy(vh1dim(1,2),ve1dim(1,2),102)
*
      do j = 4,5
       do i = 1,51
        read(11,101) vh1uim(i,j),vh1dim(i,j),vh1tuim(i,j),vh1tdim(i,j),
     &               ve1uim(i,j),ve1dim(i,j)
       enddo
      enddo
*
      do IG = 1,2
        do IT = 1,21
          do IS = 1,50
            read(11,103) vh1urenf(IS,IT,IG), vh1drenf(IS,IT,IG)
          enddo
        enddo
      enddo
*
      do IG = 1,2
        do IT = 1,21
          do IS = 1,50
            read(11,103) vh1uimnf(IS,IT,IG), vh1dimnf(IS,IT,IG)
          enddo
        enddo
      enddo
      close( 11 )
*
 101  format(6e12.4)
 102  format(4e12.4)
 103  format(2e12.4)
      end

	   SUBROUTINE UCOPY (A,B,N)
C
C CERN PROGLIB# V301    UCOPY           .VERSION KERNAPO  1.24  920511
C ORIG. 01/03/85  R.BRUN
C
      Dimension      A(*), B(*)

	  do i=1,n
       b(i)=a(i)
	  enddo 
      END

	  
	  
      subroutine nuclFF00( del2 )
C
C  Elastic nucleon's formfactors
C
      implicit double precision (A-H,O-Z)
      common/formfac/ F1pn(2), F2pn(2)
      double precision Mp, mele, pi
      common/myconst/ Mp, mele, pi
      double precision Mv, kp, kn
      parameter (Mv = 0.843D0, kp = 1.79285D0, kn = -1.91D0)
C
      dipol = 1D0/(1D0 - del2/Mv**2)**2
*
      GE_p = dipol
      GE_n = 0D0
      GM_p = (1D0 + kp)*dipol
      GM_n =        kn*dipol
*
      delm = del2/(2D0*Mp)**2
*
      F1pn(1) = (GE_p - delm*GM_p)/(1D0-delm)
      F1pn(2) = (GE_n - delm*GM_n)/(1D0-delm)
      F2pn(1) = (GM_p - GE_p)/(1D0-delm)         
      F2pn(2) = (GM_n - GE_n)/(1D0-delm)         
      return
      end

      subroutine V3subd( A, B, C)
      implicit double precision (A-H,O-Z)
      dimension A(3), B(3), C(3)
      do i = 1,3
        C(i) = A(i) - B(i)
      enddo
      end

      double precision function V3dotd( A, B)
      implicit double precision (A-H,O-Z)
      dimension A(3), B(3)
      S = 0D0
      do i = 1,3
        S = S + A(i)*B(i)
      enddo
      V3dotd = S
      end
c
      subroutine resetmom()
c
C     set to 0 all moments
      implicit none
        include "dvcsmom.inc"
c
c  BH
c
       hc0BH=0D0
       hc1BH=0D0
       hc2BH=0D0
       hc0BHlp=0D0
       hc1BHlp=0D0
       hc0BHtpcos=0D0
       hc1BHtpcos=0D0
       hs1BHtpsin=0D0
c
c  DVCS
c      
       hc0dvcs=0D0
       hc1dvcs=0D0
       hs1dvcs=0D0
       hs2dvcs=0D0
c
c  INTERF
c       
       hs1Iunp=0D0
       hc1Iunp=0D0
       hc0Iunp=0D0
       hs2Iunp=0D0
       hc2Iunp=0D0
c       
       hs1Ilp=0D0
       hc1Ilp=0D0
       hc0Ilp=0D0
c
       hs1Itpcos=0D0
       hs1Itpsin=0D0
       hc1Itpcos=0D0
       hc1Itpsin=0D0
       hc0Itpcos=0D0
       hc0Itpsin=0D0
c            
         return
         end
c
!      subroutine getphoton(Ed,xbd,Q2d,del2d,phield,phigd)
      subroutine getphoton(Ed,xbd,Q2d,del2d,phigd)
c
C     set to 0 all moments
      implicit none
*
      double precision Mp, mele, pi
      common/myconst/ Mp, mele, pi
      dimension V3k1(3), V3k2(3), V3gam(3), V3q(3)
      dimension  V3p1(3), V3p2(3), V3plus(3)
      double precision V3k1,V3k2,V3gam,V3q,V3p1, V3p2,V3plus
!      double precision Ed,xbd,Q2d,del2d,phield,phigd
      double precision Ed,xbd,Q2d,del2d,phigd
      double precision yb,nu,Esc,sintel,costel,costVq,sintVq,qmod
      double precision Ep,Egam,costgg,sintgg,Vgx,Vgy,Vgz
      double precision costeg,teteg,coste1g,tete1g,V3dotd
c
      nu  = Q2d/(2D0*Mp*xbd)
      qmod = sqrt(nu**2 + Q2d)
      yb = nu/Ed
      Esc = Ed - nu
      costel = 1D0 - Q2d/(2D0*Ed*Esc)
      sintel = sqrt(1D0 - costel**2)
c
      Ep   = Mp - del2d/(2D0*Mp)
      Egam = nu + del2d/(2D0*Mp)
c
      V3k1(1) = 0D0
      V3k1(2) = 0D0
      V3k1(3) = Ed
      V3k2(1) = Esc*sintel
      V3k2(2) = 0D0
      V3k2(3) = Esc*costel
*
      call V3subd( V3k1, V3k2, V3q)
      costVq = V3q(3)/qmod
      sintVq = sqrt(1. - costVq**2)
*
      costgg = (2D0*Egam*(Mp + nu) + Q2d - 2D0*Mp*nu)/(2D0*Egam*qmod)
      sintgg = sqrt(1D0 - costgg**2)
      Vgx = Egam*sintgg*cos(phigd)
      Vgy = Egam*sintgg*sin(phigd)
      Vgz = Egam*costgg
*
      V3gam(1) =  Vgx*costVq - Vgz*sintVq
      V3gam(2) =  Vgy
      V3gam(3) =  Vgx*sintVq + Vgz*costVq
*
      call V3subd( V3q, V3gam, V3p2)
      costeg = V3dotd( V3k1, V3gam)/(Ed*Egam)
      teteg  = acos( costeg )
      coste1g = V3dotd( V3k2, V3gam)/(Esc*Egam)
      tete1g  = acos( coste1g )
      return
      end


      
    
c$nodebug
C * * * * * * * * * * * * * * * * * * * * * * * * * * *
C *                              *
      FUNCTION URAND(IY)
C *                              *
C *   This is a standard pseudo-random generator      *
C *   that work on IBM-370 and IBM-PC. We don't       *
C *   know does it work on SUN?               *
C *                              *
C * * * * * * * * * * * * * * * * * * * * * * * * * * *
      REAL*4  URAND,S
      INTEGER*4 IY
      INTEGER*4 A,C,MASK
      PARAMETER (A  = 843314861)
      PARAMETER (C  = 453816693)
      PARAMETER (S  = 4.6566128E-10)

      IY=IAND(A*IY+C,Z'7FFFFFFF')
      URAND=FLOAT(IY)*S
      END

      subroutine simps(a1,b1,h1,reps1,aeps1,funct,x,ai,aih,aiabs)
c simps
c a1,b1 -the limits of integration
c h1 -an initial step of integration
c reps1,aeps1 - relative and absolute precision of integration
c funct -a name of function subprogram for calculation of integrand +
c x - an argument of the integrand
c ai - the value of integral
c aih- the value of integral with the step of integration
c aiabs- the value of integral for module of the integrand
c this subrogram calculates the definite integral with the relative or
c absolute precision by simpson+s method with the automatical choice
c of the step of integration
c if aeps1    is very small(like 1.e-17),then calculation of integral
c with reps1,and if reps1 is very small (like 1.e-10),then calculation
c of integral with aeps1
c when aeps1=reps1=0. then calculation with the constant step h1
c
      implicit real*8(a-h,o-z)
      dimension f(7),p(5)
      h=dsign(h1,b1-a1)
      s=dsign(1.d0,h)
      a=a1
      b=b1
      ai=0.d0
      aih=0.d0
      aiabs=0.d0
      p(2)=4.d0
      p(4)=4.d0
      p(3)=2.d0
      p(5)=1.d0
      if(b-a) 1,2,1
    1 reps=dabs(reps1)
      aeps=dabs(aeps1)
      do 3 k=1,7
  3   f(k)=10.d16
      x=a
      c=0.d0
      f(1)=funct(x)/3.
    4 x0=x
      if((x0+4.*h-b)*s) 5,5,6
    6 h=(b-x0)/4.
      if(h) 7,2,7
    7 do 8 k=2,7
  8   f(k)=10.d16
      c=1.d0
    5 di2=f(1)
      di3=dabs(f(1))
      do 9 k=2,5
      x=x+h
      if((x-b)*s) 23,24,24
   24 x=b
   23 if(f(k)-10.d16) 10,11,10
   11 f(k)=funct(x)/3.
   10 di2=di2+p(k)*f(k)
    9 di3=di3+p(k)*abs(f(k))
      di1=(f(1)+4.*f(3)+f(5))*2.*h
      di2=di2*h
      di3=di3*h
      if(reps) 12,13,12
   13 if(aeps) 12,14,12
   12 eps=dabs((aiabs+di3)*reps)
      if(eps-aeps) 15,16,16
   15 eps=aeps
   16 delta=dabs(di2-di1)
      if(delta-eps) 20,21,21
   20 if(delta-eps/8.) 17,14,14
   17 h=2.*h
      f(1)=f(5)
      f(2)=f(6)
      f(3)=f(7)
      do 19 k=4,7
  19  f(k)=10.d16
      go to 18
   14 f(1)=f(5)
      f(3)=f(6)
      f(5)=f(7)
      f(2)=10.d16
      f(4)=10.d16
      f(6)=10.d16
      f(7)=10.d16
   18 di1=di2+(di2-di1)/15.
      ai=ai+di1
      aih=aih+di2
      aiabs=aiabs+di3
      go to 22
   21 h=h/2.
      f(7)=f(5)
      f(6)=f(4)
      f(5)=f(3)
      f(3)=f(2)
      f(2)=10.d16
      f(4)=10.d16
      x=x0
      c=0.d0
      go to 5
   22 if(c) 2,4,2
    2 return
      end

      subroutine simpxx(a,b,np,ep,func,res)
      implicit real*8 (a-h,o-z)
      external func
      step=(b-a)/np
      call simps(a,b,step,ep,1d-18,func,ra,res,r2,r3)
      end
