!*****************************************************************************************
!>double precision function find diffusivity - returns the diffusivity of a given defect type
!!
!! This function looks up the diffusivity of a given defect type using input date from 
!! material parameter input file. It either looks up diffusivity from values in a list or
!! computes diffusivity using diffusivityCompute in the case of a functional form.
!!
!!Input: defect type
!!Output: diffusivity (nm^2/s)
!*****************************************************************************************

double precision function findDiffusivity(matNum, defectType)
use DerivedType
use mod_constants
implicit none

integer defectType(numSpecies)
integer i, j, numSame, matNum
double precision Diff
double precision DiffusivityCompute

!Temporary: used as a parameter to vary the diffusivity of all defects on GB
double precision, parameter :: Param=0d0

!***************************************************************************************************
!This function returns the diffusivity of defect DefectType.
!It searches to see if DefectType is listed in DiffSingle, and if not, if it is listed in DiffFunction.
!If it is in neither, it outputs an error message (defect type should not exist)
!***************************************************************************************************

outer: do i=1,numSingleDiff(matNum)
	numSame=0
	do j=1,numSpecies
		if(DefectType(j)==DiffSingle(matNum,i)%defectType(j)) then
			numSame=numSame+1
		end if
	end do
	if (numSame==numSpecies) then
		if(matNum==2) then
			if(DefectType(1)==1 .AND. DefectType(2)==0 .AND. DefectType(3)==0 .AND. DefectType(4)==0 &
					.AND. totalDPA > 0d0 .AND. DPARate > 0d0) then
				Diff=DiffSingle(matNum,i)%D*dexp(-(DiffSingle(matNum,i)%Em-Param)/(kboltzmann*temperature)) * &
							(Vconcent / initialCeqv)
				exit outer
			else
				Diff=DiffSingle(matNum,i)%D*dexp(-(DiffSingle(matNum,i)%Em-Param)/(kboltzmann*temperature))
				exit outer
			end if

		else
			if(DefectType(1)==1 .AND. DefectType(2)==0 .AND. DefectType(3)==0 .AND. DefectType(4)==0 &
					.AND. totalDPA > 0d0 .AND. DPARate > 0d0) then
				Diff=DiffSingle(matNum,i)%D*dexp(-DiffSingle(matNum,i)%Em/(kboltzmann*temperature)) * &
					(Vconcent / initialCeqv)
				exit  outer
			else
				Diff=DiffSingle(matNum,i)%D*dexp(-DiffSingle(matNum,i)%Em/(kboltzmann*temperature))
				exit outer
			end if
		
		end if
	end if
end do outer

if(i==numSingleDiff(matNum)+1) then	!did not find defect in single defect list
	do i=1,numFuncDiff(matNum)
		numSame=0
		do j=1,numSpecies
			if(DefectType(j)==0 .AND. DiffFunc(matNum,i)%defectType(j)==0) then
				numSame=numSame+1
			else if(DefectType(j) /= 0 .AND. DiffFunc(matNum,i)%defectType(j)==1) then
				if(DefectType(j) >= DiffFunc(matNum,i)%min(j)) then
				if(DefectType(j) <= DiffFunc(matNum,i)%max(j) .OR. DiffFunc(matNum,i)%max(j)==-1) then
					numSame=numSame+1
				endif
				endif
			endif
		end do
		if(numSame==numSpecies) then
		
			Diff=DiffusivityCompute(DefectType, DiffFunc(matNum,i)%functionType, DiffFunc(matNum,i)%numParam,&
				DiffFunc(matNum,i)%parameters, matNum)
				exit
		endif
	end do
	if(i==numFuncDiff(matNum)+1) then
		!write(*,*) 'error defect diffusion not allowed'
		!write(*,*) DefectType
		Diff=0d0
	endif
endif

findDiffusivity=Diff
end function

!*****************************************************************************************
!>double precision function diffusivityCompute - computes diffusivity using a functional form
!! for defects that don't have their diffusivity given by a value in a list.
!!
!! This function has several hard-coded functional forms for diffusivity, including immobile
!! defects, constant functions, and mobile SIA loops. Additional functional forms can be added
!! as needed.
!*****************************************************************************************

double precision function DiffusivityCompute(DefectType, functionType, numParameters, parameters,matNum)
use mod_constants
use DerivedType
implicit none

integer DefectType(numSpecies)
integer functionType, numParameters, matNum
double precision parameters(numParameters)
double precision Diff
double precision D0, Em

!***************************************************************************************************
!This function computes diffusivity using functional form and parameters given in the input file
!***************************************************************************************************

if(functionType==1) then
	!used for immobile defects
	Diff=0d0
else if(functionType==2) then
	!used for constant functions
	Diff=parameters(1)
else if(functionType==3) then
	!Mobile defect diffusivity
	D0=parameters(1)+parameters(2)/dble(DefectType(3))**(parameters(3))
	Em=parameters(4)+parameters(5)/dble(DefectType(3))**(parameters(6))
	
	Diff=D0*dexp(-Em/(kboltzmann*temperature))
else if(functionType==5) then
	!< Dcu(n) = Dcu(1)/n
	if(totalDPA > 0d0 .AND. DPARate > 0d0) then
		Diff=(DiffSingle(matNum,1)%D*dexp(-DiffSingle(1,1)%Em/(kboltzmann*temperature)))*(Vconcent / initialCeqv)/ &
				dble(DefectType(1))

	else
		Diff=(DiffSingle(matNum,1)%D*dexp(-DiffSingle(1,1)%Em/(kboltzmann*temperature)))/dble(DefectType(1))
	end if
else
	write(*,*) 'error incorrect diffusivity function chosen'
endif

DiffusivityCompute=Diff

end function


!**********************************************************************************
!This function is used to compute the vacancy concentration at this time
!This function will not be used
!**********************************************************************************
double precision function permanentCv(matNum)
	use DerivedType
	use mod_constants
	implicit none

	double precision Kiv, diffV, diffI
	integer matNum

	diffV = DiffSingle(matNum,2)%D*dexp(-DiffSingle(matNum,2)%Em/(kboltzmann*temperature))
	diffI = DiffSingle(matNum,6)%D*dexp(-DiffSingle(matNum,6)%Em/(kboltzmann*temperature))

	Kiv = 4*pi/atomsize*reactionRadius*(diffV + diffI)

	permanentCv = -dislocationDensity*Zint*diffI/(2*Kiv)+&
			((dislocationDensity*Zint*diffI/(2*Kiv))**(2d0)+DPARate*Zint*diffI/(Kiv*diffV))**(1d0/2d0)

end function

!***************************************************************************************************
!This function returns the binding energy of defect DefectType() which releases defect product().
!It searches to see if DefectType and product are listed in BindSingle, and if not, in BindFunc.
!If they are in neither, it outputs an error message (cannot dissociate that product from that defect)
!***************************************************************************************************

!*****************************************************************************************
!>double precision function find binding - returns the binding energy of a given defect type
!!
!! This function looks up the binding energy of a given defect type using input data from 
!! material parameter input file. It either looks up binding energy from values in a list or
!! computes binding energy using bindingCompute in the case of a functional form.
!!
!!Input: defect type, product type (what type of defect dissociates from the cluster)
!!Output: binding energy (eV)
!*****************************************************************************************

double precision function findBinding(matNum, DefectType, productType)
use DerivedType
use mod_constants
implicit none

integer DefectType(numSpecies), productType(numSpecies)
integer i, j, numSame, numSameProduct, matNum
double precision Eb
double precision BindingCompute

!Temporary: used as a parameter to vary the binding energy of all defects on GB
double precision, parameter :: Param=0d0

do i=1,numSingleBind(matNum)
	numSame=0
	numSameProduct=0
	do j=1,numSpecies
		if(DefectType(j)==BindSingle(matNum,i)%defectType(j)) then
			numSame=numSame+1
		endif
		if(productType(j)==BindSingle(matNum,i)%product(j)) then
			numSameProduct=numSameProduct+1
		endif
	end do
	if (numSame==numSpecies .AND. numSameProduct==numSpecies) then
		if(matNum==2) then
			
			Eb=BindSingle(matNum,i)%Eb-Param
			exit
			
		else
		
			Eb=BindSingle(matNum,i)%Eb
			exit
			
		endif
	endif
end do

if(i==numSingleBind(matNum)+1) then	!did not find defect in single defect list
	do i=1,numFuncBind(matNum)
		numSame=0
		numSameProduct=0
		do j=1,numSpecies
			if(DefectType(j)==0 .AND. BindFunc(matNum,i)%defectType(j)==0) then
				numSame=numSame+1
			else if(DefectType(j) /= 0 .AND. BindFunc(matNum,i)%defectType(j)==1) then
				if(DefectType(j) >= BindFunc(matNum,i)%min(j)) then
				if(DefectType(j) <= BindFunc(matNum,i)%max(j) .OR. BindFunc(matNum,i)%max(j)==-1) then
					numSame=numSame+1
				endif
				endif
			endif
			if(productType(j)==0 .AND. BindFunc(matNum,i)%product(j)==0) then
				numSameProduct=numSameProduct+1
			else if(productType(j) == 1 .AND. BindFunc(matNum,i)%product(j)==1) then	!used to find dissociation binding energy
				numSameProduct=numSameProduct+1
			else if(productType(j) /= 0 .AND. BindFunc(matNum,i)%product(j)==-1) then	!used to identify de-pinning binding energy
				numSameProduct=numSameProduct+1
			endif
		end do
		if(numSame==numSpecies .AND. numSameProduct==numSpecies) then
			
			if(matNum==2) then	!Adjust binding energies on GB
			
				Eb=BindingCompute(DefectType, productType, BindFunc(matNum,i)%functionType, BindFunc(matNum,i)%numParam,&
					BindFunc(matNum,i)%parameters)-Param
				exit
				
			else
			
				Eb=BindingCompute(DefectType, productType, BindFunc(matNum,i)%functionType, BindFunc(matNum,i)%numParam,&
					BindFunc(matNum,i)%parameters)
				exit
				
			endif
			
		endif
	end do
	if(i==numFuncBind(matNum)+1) then
		!write(*,*) 'error dissociation reaction not allowed'
		!write(*,*) DefectType
		!write(*,*) ProductType
		Eb=0d0
	end if
end if

if(Eb < 0d0) then
	Eb=0d0
end if

findBinding=Eb
end function

!*****************************************************************************************
!>double precision function bindingCompute - computes binding energy using a functional form
!! for defects that don't have their binding energy given by a value in a list.
!!
!! This function has several hard-coded functional forms for binding energy, including vacancy
!! clusters, SIA clusters, He/V clusters, and the activation energy for a sessile-glissile
!!SIA loop transformation
!*****************************************************************************************


double precision function BindingCompute(DefectType, product, functionType, numParameters, parameters)
use mod_constants
implicit none

integer DefectType(numSpecies), product(numSpecies)
integer functionType, numParameters, num, CuNum, VNum, SIANum, i
double precision parameters(numParameters)
double precision Eb, Eb_VOnly, Eb_HeV

!***************************************************************************************************
!This function computes diffusivity using functional form and parameters given in the input file
!***************************************************************************************************

if(functionType==2) then
	!used for Cu cluster dislocation
	Eb=parameters(1)*kboltzmann-parameters(2)*kboltzmann*tempStore- &
			(36d0*pi)**(1d0/3d0)*atomsize**(2d0/3d0)*parameters(3)*(dble(CuNum)**(2d0/3d0)-dble(CuNum-1)**(2d0/3d0))

else if(functionType==4) then
	num=0
	do i=1,numSpecies
		if(DefectType(i) > num) then
			num=DefectType(i)
		endif
	end do

	Eb=parameters(1)+(parameters(2)-parameters(1))*(dble(num)**(2d0/3d0)-dble(num-1)**(2d0/3d0))/(2d0**(2d0/3d0)-1d0)

else if(functionType==6) then
	CuNum=DefectType(1)
	VNum=DefectType(2)
	Eb=parameters(1)+parameters(2)*(dble(CuNum)**(0.85d0)-dble(CuNum+1)**(0.85d0))-&
			parameters(3)*(dble(VNum)**(1d0/3d0)-dble(VNum)**(2d0/3d0))

else if(functionType==7) then
	CuNum=DefectType(1)
	VNum=DefectType(2)
	Eb=parameters(1)-parameters(2)*(dble(VNum)**(1d0/3d0)-dble(VNum+1)**(1d0/3d0))+&
			parameters(3)*(dble(VNum)**(2d0/3d0)-dble(VNum+1)**(2d0/3d0))-parameters(3)*dble(CuNum)*&
			(dble(VNum)**(1d0/3d0)-dble(VNum+1)**(1d0/3d0)+dble(VNum)**(2d0/3d0)-dble(VNum+1)**(2d0/3d0))

!!else if(functionType==8) then
	
	!SIA sessile - glissile binding energy
	!Using (made-up) empirical functional form
!	SIANum=DefectType(4)
	
	!2/3 power law
	!Eb=parameters(1)-parameters(2)*(dble(SIANum)**(2d0/3d0)-dble(SIANum-1)**(2d0/3d0))
	
	!linear binding energy dependence

	! Reference:
!!	Eb=parameters(1)*SIANum+parameters(2)

else
	write(*,*) 'error incorrect Eb function chosen'
endif

BindingCompute=Eb

end function

!*****************************************************************************************
!>integer function findDefectSize - returns the size of a cluster
!!
!!This function will find the effective size of the defect (hard-coded information), used for determining
!!the radius of the defect (for dissociation and clustering reactions).
!!It returns n, the number of lattice spaces taken up by this defect.
!!
!!NOTE: for He_nV_m clusters, this function returns the larger of m or n
!*****************************************************************************************

integer function findDefectSize(defectType)
use mod_constants
implicit none

integer defectType(numSpecies), max, i

!Hard-coded below and may be changed if the rules for defect size change.
max=0
do i=1, numSpecies
	if(defectType(i) > max) then
		max=defectType(i)
	endif
end do

findDefectSize=max
end function

!*****************************************************************************************
!>double precision function findStrainEnergy - Returns the interaction energy of the defect with the local strain field
!!
!!This function takes the double dot product of the defect's dipole tensor with the local
!!strain field and returns that amount (energy, in eV). 
!!
!!NOTE: if the dipole tensor is asymmetric, an averaged strain energy is taken which
!!accounts for all possible orientations of the defect. It is not known if this is the 
!!correct averaging procedure that should be used here.
!*****************************************************************************************

double precision function findStrainEnergy(defectType, cell)
use DerivedType
use mod_constants
implicit none

integer i, j, same
double precision strainE
integer defectType(numSpecies)
integer cell

strainE=0d0

do i=1,numDipole
	
	!search for defect type in dipole tensor
	same=0
	do j=1,numSpecies
		if(defectType(j) >= dipoleStore(i)%min(j) .AND. defectType(j) <= dipoleStore(i)%max(j)) then
			same=same+1
		endif
	end do
	
	if(same==numSpecies) then
		exit
	endif
	
end do

if(i <= numDipole) then	!we have identified a dipole tensor
	write(*,*) 'finding strain energy'
	write(*,*) defectType
	
	do j=1,6
		if(j <= 3) then
			strainE=strainE+myMesh(cell)%strain(j)*dipoleStore(i)%equilib(j)
		else
			strainE=strainE+2d0*myMesh(cell)%strain(j)*dipoleStore(i)%equilib(j)
		endif
		write(*,*) 'j', j, 'strain', myMesh(cell)%strain(j), 'dipole', dipoleStore(i)%equilib(j)
	end do

	read(*,*)
endif

findStrainEnergy=strainE

end function


!*****************************************************************************************
!>double precision function findStrainEnergyBoundary - Returns the interaction energy of the defect with the local strain field in a boundary element
!!
!!This function takes the double dot product of the defect's dipole tensor with the local
!!strain field and returns that amount (energy, in eV). 
!!
!!NOTE: if the dipole tensor is asymmetric, an averaged strain energy is taken which
!!accounts for all possible orientations of the defect. It is not known if this is the 
!!correct averaging procedure that should be used here.
!*****************************************************************************************

double precision function findStrainEnergyBoundary(defectType, dir, cell)
use DerivedType
use mod_constants
implicit none

integer i, j, same
double precision strainE
integer defectType(numSpecies)
integer cell, dir

strainE=0d0

do i=1,numDipole
	
	!search for defect type in dipole tensor
	same=0
	do j=1,numSpecies
		if(defectType(j) >= dipoleStore(i)%min(j) .AND. defectType(j) <= dipoleStore(i)%max(j)) then
			same=same+1
		endif
	end do
	
	if(same==numSpecies) then
		exit
	endif
	
end do

if(i <= numDipole) then	!we have identified a dipole tensor

	do j=1,6
		if(j <= 3) then
			strainE=strainE+myBoundary(dir,cell)%strain(j)*dipoleStore(i)%equilib(j)
		else
			strainE=strainE+2d0*myBoundary(dir,cell)%strain(j)*dipoleStore(i)%equilib(j)
		endif
	end do

endif

findStrainEnergyBoundary=strainE

end function
