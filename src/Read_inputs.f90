!***************************************************************************************************
!>Subroutine read material input - reads material input information from file
!!
!!Information read in includes:
!!
!!1) Allowed defects and their diffusion rates and binding energies
!!
!!2) Allowed reactions, including single, multi, diffusion, and implantation reactions
!!
!!NOTE: we are double-reading in the values of numSingleDiff(matNum), etc, because it has
!!already been done in the subroutine readReactionListSizes().
!***************************************************************************************************
subroutine readMaterialInput(filename)	!read FeCu_Defects.txt
use DerivedType
use mod_constants
implicit none

integer i, j, count
character*20 :: char
character*50 :: filename
integer, allocatable :: DefectType(:), productType(:)
!type(reaction), pointer :: reactions, reactionCurrent
logical flag
Double precision Diff, Eb
integer matNum

open(80, file=filename,action='read', status='old') !read xx_Defects.txt

flag=.FALSE.

!The following is for the entire parameter set

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='material') then
		flag=.TRUE.
		read(80,*) matNum
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='species') then	
		flag=.TRUE.
		read(80,*) numSpecies
	end if
end do
flag=.FALSE.

!************************************************
!The following is for formation energies parameters only
!************************************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='formationEnergies') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleForm(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='single') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do i=1,numSingleForm(matNum)
	allocate(FormSingle(i,matNum)%defectType(numSpecies))
	read(80,*) (FormSingle(i,matNum)%defectType(j),j=1,numSpecies)
	read(80,*) char, FormSingle(i,matNum)%Ef
end do

!************************************************
!The following is for diffusivity parameters only
!************************************************

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='diffusionPrefactors') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleDiff(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numFunction') then
		flag=.TRUE.
		read(80,*) numFuncDiff(matNum)
	end if
end do
flag=.FALSE.

!allocate(DiffSingle(numSingleDiff))
!allocate(DiffFunc(numFuncDiff))

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='single') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!write(*,*) 'reading single defect diffusion, proc', myProc%taskid
do i=1,numSingleDiff(matNum)
	allocate(DiffSingle(i,matNum)%defectType(numSpecies))
	read(80,*) (DiffSingle(i,matNum)%defectType(j),j=1,numSpecies)
	read(80,*) char, DiffSingle(i,matNum)%D, char, DiffSingle(i,matNum)%Em
end do

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='function') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!write(*,*) 'reading function diffusion values', myProc%taskid
do i=1,numFuncDiff(matNum)
	allocate(DiffFunc(i,matNum)%defectType(numSpecies))
	read(80,*) (DiffFunc(i,matNum)%defectType(j),j=1,numSpecies)	!< read in defectTypes
	count=0
	!We need to know min and max sizes for each defect type included
	allocate(DiffFunc(i,matNum)%min(numSpecies))
	allocate(DiffFunc(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, DiffFunc(i,matNum)%min(j), char, DiffFunc(i,matNum)%max(j)	!< read in min and max
	end do
	read(80,*) char, DiffFunc(i,matNum)%functionType, char, DiffFunc(i,matNum)%numParam	!< read in functionType and numParm
	allocate(DiffFunc(i,matNum)%parameters(DiffFunc(i,matNum)%numParam))
	read(80,*) (DiffFunc(i,matNum)%parameters(j),j=1,DiffFunc(i,matNum)%numParam)	!< read in paramsters
end do

!*****************************************************
!The following is for binding energies parameters only
!*****************************************************

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='bindingEnergies') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!write(*,*) 'reading binding energies', myProc%taskid

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleBind(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numFunction') then
		flag=.TRUE.
		read(80,*) numFuncBind(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='single') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!allocate(BindSingle(numSingleBind))
!allocate(BindFunc(numFuncBind))

do i=1,numSingleBind(matNum)
	allocate(BindSingle(i,matNum)%defectType(numSpecies))
	allocate(BindSingle(i,matNum)%product(numSpecies))
	read(80,*) (BindSingle(i,matNum)%defectType(j),j=1,numSpecies), (BindSingle(i,matNum)%product(j),j=1,numSpecies)
	read(80,*) char, BindSingle(i,matNum)%Eb
end do

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='function') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!write(*,*) 'reading function binding values', myProc%taskid
do i=1,numFuncBind(matNum)
	allocate(BindFunc(i,matNum)%defectType(numSpecies))
	allocate(BindFunc(i,matNum)%product(numSpecies))
	read(80,*) (BindFunc(i,matNum)%defectType(j),j=1,numSpecies), (BindFunc(i,matNum)%product(j),j=1,numSpecies)
	allocate(BindFunc(i,matNum)%min(numSpecies))
	allocate(BindFunc(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, BindFunc(i,matNum)%min(j), char, BindFunc(i,matNum)%max(j)
	end do
	read(80,*) char, BindFunc(i,matNum)%functionType, char, BindFunc(i,matNum)%numParam
	allocate(BindFunc(i,matNum)%parameters(BindFunc(i,matNum)%numParam))
	read(80,*) (BindFunc(i,matNum)%parameters(j),j=1,BindFunc(i,matNum)%numParam)
end do

!******************************************************************
!Construct reaction list using migration and binding energies above
!******************************************************************

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='singleDefect') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!********************** dissociation *******************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='dissociation') then
		flag=.TRUE.
		read(80,*) numDissocReac(matNum)
	end if
end do
flag=.FALSE.

!write(*,*) 'reading dissociation reactions', myProc%taskid

!allocate(DissocReactions(numDissocReac))
do i=1,numDissocReac(matNum)
	DissocReactions(i,matNum)%numReactants=1
	DissocReactions(i,matNum)%numProducts=1
	allocate(DissocReactions(i,matNum)%reactants(numSpecies,DissocReactions(i,matNum)%numReactants))
	allocate(DissocReactions(i,matNum)%products(numSpecies,DissocReactions(i,matNum)%numProducts))
	read(80,*) (DissocReactions(i,matNum)%reactants(j,1),j=1,numSpecies),&
		(DissocReactions(i,matNum)%products(j,1),j=1,numSpecies)	!< read in defectType
	allocate(DissocReactions(i,matNum)%min(numSpecies))
	allocate(DissocReactions(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, DissocReactions(i,matNum)%min(j), char, DissocReactions(i,matNum)%max(j)
	end do
	read(80,*) DissocReactions(i,matNum)%functionType
end do


!********************** diffusion *******************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='diffusion') then
		flag=.TRUE.
		read(80,*) numDiffReac(matNum)
	end if
end do
flag=.FALSE.

!allocate(DiffReactions(numDiffReac))
do i=1,numDiffReac(matNum)
	DiffReactions(i,matNum)%numReactants=1
	DiffReactions(i,matNum)%numProducts=1
	allocate(DiffReactions(i,matNum)%reactants(numSpecies,DiffReactions(i,matNum)%numReactants))
	allocate(DiffReactions(i,matNum)%products(numSpecies,DiffReactions(i,matNum)%numProducts))
	read(80,*) (DiffReactions(i,matNum)%reactants(j,1),j=1,numSpecies),&
		(DiffReactions(i,matNum)%products(j,1),j=1,numSpecies)
	allocate(DiffReactions(i,matNum)%min(numSpecies))
	allocate(DiffReactions(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, DiffReactions(i,matNum)%min(j), char, DiffReactions(i,matNum)%max(j)
	end do
	read(80,*) DiffReactions(i,matNum)%functionType
end do

!********************** sinkRemoval *******************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='sinkRemoval') then
		flag=.TRUE.
		read(80,*) numSinkReac(matNum)
	end if
end do
flag=.FALSE.

!allocate(SinkReactions(numSinkReac))
do i=1,numSinkReac(matNum)
	SinkReactions(i,matNum)%numReactants=1
	SinkReactions(i,matNum)%numProducts=0
	allocate(SinkReactions(i,matNum)%reactants(numSpecies,SinkReactions(i,matNum)%numReactants))
	read(80,*) (SinkReactions(i,matNum)%reactants(j,1),j=1,numSpecies)
	allocate(SinkReactions(i,matNum)%min(numSpecies))
	allocate(SinkReactions(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, SinkReactions(i,matNum)%min(j), char, SinkReactions(i,matNum)%max(j)
	end do
	read(80,*) SinkReactions(i,matNum)%functionType
end do


!********************** impurityTrapping *******************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='impurityTrapping') then
		flag=.TRUE.
		read(80,*) numImpurityReac(matNum)
	end if
end do
flag=.FALSE.

!allocate(ImpurityReactions(numImpurityReac))
do i=1,numImpurityReac(matNum)
	ImpurityReactions(i,matNum)%numReactants=1
	ImpurityReactions(i,matNum)%numProducts=1
	allocate(ImpurityReactions(i,matNum)%reactants(numSpecies,ImpurityReactions(i,matNum)%numReactants))
	allocate(ImpurityReactions(i,matNum)%products(numSpecies,ImpurityReactions(i,matNum)%numProducts))
	read(80,*) (ImpurityReactions(i,matNum)%reactants(j,1),j=1,numSpecies), &
		(ImpurityReactions(i,matNum)%products(j,1),j=1,numSpecies)
	allocate(ImpurityReactions(i,matNum)%min(numSpecies))
	allocate(ImpurityReactions(i,matNum)%max(numSpecies))
	do j=1,numSpecies
		read(80,*) char, ImpurityReactions(i,matNum)%min(j), char, ImpurityReactions(i,matNum)%max(j)
	end do
	read(80,*) ImpurityReactions(i,matNum)%functionType
end do

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='multipleDefect') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.


!********************** clustering *******************************
do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='clustering') then
		flag=.TRUE.
		read(80,*) numClusterReac(matNum)
	end if
end do
flag=.FALSE.

!allocate(ClusterReactions(numClusterReac))
do i=1,numClusterReac(matNum)
	ClusterReactions(i,matNum)%numReactants=2
	ClusterReactions(i,matNum)%numProducts=1
	allocate(ClusterReactions(i,matNum)%reactants(numSpecies,ClusterReactions(i,matNum)%numReactants))
	allocate(ClusterReactions(i,matNum)%products(numSpecies,ClusterReactions(i,matNum)%numProducts))
	read(80,*) (ClusterReactions(i,matNum)%reactants(j,1),j=1,numSpecies),&
		(ClusterReactions(i,matNum)%reactants(j,2),j=1,numSpecies)
	allocate(ClusterReactions(i,matNum)%min(numSpecies*ClusterReactions(i,matNum)%numReactants))
	allocate(ClusterReactions(i,matNum)%max(numSpecies*ClusterReactions(i,matNum)%numReactants))
	do j=1,numSpecies*ClusterReactions(i,matNum)%numReactants
		read(80,*) char, ClusterReactions(i,matNum)%min(j), char, ClusterReactions(i,matNum)%max(j)
	end do
	do j=1,numSpecies
		!ClusterReactions products are reaction-specific, and are not correctly found here. This is just a placeholder.
		ClusterReactions(i,matNum)%products(j,1)=ClusterReactions(i,matNum)%reactants(j,1)+&
												 ClusterReactions(i,matNum)%reactants(j,2)
	end do
	read(80,*) ClusterReactions(i,matNum)%functionType
end do


do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='noDefect') then
		flag=.TRUE.
		read(80,*) numImplantReac(matNum)
	end if
end do
flag=.FALSE.

!allocate(ImplantReactions(numImplantReac))
!********************** FrenkelPair Implantation *******************************
do i=1,numImplantReac(matNum)
	if(i==1) then	!Read in Frenkel pair reaction parameters

		do while(flag .eqv. .FALSE.)
			read(80,*) char
			if(char=='FrenkelPair') then
				flag=.TRUE.
			end if
		end do
		flag=.FALSE.
		
		!write(*,*) 'reading frenkel pair reactions', myProc%taskid
		
		ImplantReactions(i,matNum)%numReactants=0
		ImplantReactions(i,matNum)%numProducts=2
		allocate(ImplantReactions(i,matNum)%products(numSpecies,ImplantReactions(i,matNum)%numProducts))
		read(80,*) (ImplantReactions(i,matNum)%products(j,1),j=1,numSpecies),&
			(ImplantReactions(i,matNum)%products(j,2),j=1,numSpecies)
		read(80,*) ImplantReactions(i,matNum)%functionType

	else if(i==2) then !read in cascade reaction parameters

		do while(flag .eqv. .FALSE.)
			read(80,*) char
			if(char=='Cascade') then
				flag=.TRUE.
			end if
		end do
		flag=.FALSE.

		ImplantReactions(i,matNum)%numReactants=-10
		ImplantReactions(i,matNum)%numProducts=0
		read(80,*) ImplantReactions(i,matNum)%functionType

	else
		write(*,*) 'error numImplantReac'
	end if
end do

close(80)
end subroutine

!***************************************************************************************************
!
!> Subroutine readCascadeList() - reads defects in cascades and locations from a file
!!
!! This subroutine reads a list of cascades from a file (name given in readParameters).
!! This information is stored in derived type cascadeEvent and used whenever a cascade is chosen
!! throughout the duration of the program.
!
!***************************************************************************************************
subroutine readCascadeList()
use mod_constants
use DerivedType
implicit none

type(cascadeEvent), pointer :: cascadeCurrent
type(cascadeDefect), pointer :: defectCurrent
integer i, numDefects, j, k
character*20 char
character*50 filename
logical flag

!read in implantation type
flag=.FALSE.
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='implantType') then
		read(81,*) implantType
		flag=.TRUE.
	end if
end do

!read in cascade implantation scheme (Monte Carlo or explicit)
flag=.FALSE.
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='implantScheme') then
		read(81,*) implantScheme
		flag=.TRUE.
	end if
end do

!Check to make sure that we only are choosing explicit implantation with cascades
if(implantScheme=='explicit' .AND. implantType=='FrenkelPair') then
	write(*,*) 'error frenkel pairs with explicit implantation'
endif

!read in filename of cascade file
flag=.FALSE.
do while (flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='cascadeFile') then
		read(81,*) filename			!read in filename of cascade input file from parameters.txt
		flag=.TRUE.
	end if
end do

flag=.FALSE.
do while (flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='meshingType') then
		read(81,*) meshingType		!read whether we are using adaptive meshing or fine meshing
		flag=.TRUE.
	end if
end do

if(implantType=='Cascade') then

	open(80, file=filename,action='read', status='old')

	allocate(cascadeList)
	cascadeCurrent=>cascadeList
	read(80,*) numDisplacedAtoms
	read(80,*)
	read(80,*) numCascades
	
	do i=1,numCascades
		read(80,*)
		read(80,*) numDefects
		read(80,*) cascadeCurrent%numDisplacedAtoms
		cascadeCurrent%NumDefectsTotal=numDefects
		allocate(cascadeCurrent%ListOfDefects)
		defectCurrent=>cascadeCurrent%ListOfDefects
		nullify(cascadeCurrent%nextCascade)
		nullify(defectCurrent%next)
		
		do j=1,numDefects
			allocate(defectCurrent%defectType(numSpecies))
			read(80,*) (defectCurrent%defectType(k),k=1,numSpecies)
			read(80,*) (defectCurrent%coordinates(k), k=1,3)
			
			if(j /= numDefects) then
				allocate(defectCurrent%next)
				nullify(defectCurrent%next%next)
				defectCurrent=>defectCurrent%next
			end if
		end do
		
		if(i /= numCascades) then
			allocate(cascadeCurrent%nextCascade)
			cascadeCurrent=>cascadeCurrent%nextCascade
		end if
	end do
	nullify(defectCurrent)
	nullify(cascadeCurrent)

	close(80)

else if(implantType=='FrenkelPair') then
	numDisplacedAtoms=1				!Frenkel pair implantation, no need to read cascades, one displaced atom per implant event
else
	write(*,*) 'error implantType'
endif

end subroutine

!***************************************************************************************************
!
!> Subroutine readImplantData() - reads non-uniform implantation profiles (damage and helium)
!!
!! This subroutine recognizes whether we are in a uniform implantation scheme or a non-uniform implantation
!! scheme. If the implantation is non-uniform, this subroutine reads from a file the implantation
!! profile (in dpa/s for each material point).
!!
!! Note: as constructed, this is hard-coded to read in one-dimensional DPA and He implantation rates
!! (for DPA profiles through the thickness of a material, for example), instead of full 3D DPA distributions.
!! This is typically for thin films with implantation profiles that vary through their depth.
!!
!! This is written such that the input file does not have to have the same number of points with the
!! same z-coordinates as the elements in the mesh. The code will interpolate from the input file what
!! the DPA rate and He implant rate should be in each element. However, if the size of the input file
!! is smaller than the size of the mesh in the z-direction, it will return an error.
!!
!! Inputs: file with DPA and He implant rates in z-coordinates
!! Outputs: information is stored in a global array.
!
!***************************************************************************************************
subroutine readImplantData()
use DerivedType
use mod_constants
implicit none

logical flag
character*20 char
character*50 filename
integer i, j

!read in toggle for non-unifrm distribution
flag=.FALSE.
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='implantDist') then
		read(81,*) implantDist
		flag=.TRUE.
	end if
end do

flag=.FALSE.
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='implantFile') then
		read(81,*) filename
		flag=.TRUE.
	end if
end do

if(implantDist=='Uniform') then
	!Do nothing, no need to read information from file
else if(implantDist=='NonUniform') then
	
	!Read in implantation profile from file and store in a double precision array.
	open(80, file=filename,action='read', status='old')
	
	flag=.FALSE.
	do while(flag .eqv. .FALSE.)
		read(80,*) char
		if(char=='numImplantDataPoints') then
			read(80,*) numImplantDataPoints
			flag=.TRUE.
		end if
	end do
	
	!Allocate the array containing information on DPA rates with numImplantDataPoints rows and
	!3 columns (z-coordinates, DPA rate, He implant rate)

	!2019.05.06 modify: no He
	!allocate(implantRateData(numImplantDataPoints,3))
	allocate(implantRateData(2,numImplantDataPoints))
	
	flag=.FALSE.
	do while(flag .eqv. .FALSE.)
		read(80,*) char
		if(char=='start') then
			flag=.TRUE.
		end if
	end do
	
	!Read implant information from file
	do i=1,numImplantDataPoints
		!2019.05.06 modify: no He
		!read(80,*) (implantRateData(i,j),j=1,3)
		read(80,*) (implantRateData(j,i),j=1,2)
	end do
	
	close(80)
	
else
	write(*,*) 'Error: unknown implantation distribution'
endif

end subroutine

!***************************************************************************************************
!> Subroutine selectMaterialInputs() - controlling subroutines that calls other subroutines to read inputs.
!!
!! This subroutine reads the name of the material input file(s) and then reads in relevant material
!! constants (binding and migration energies, number of species, allowed reactions, reaction functional
!! forms, etc)
!
!***************************************************************************************************
subroutine selectMaterialInputs()
use mod_constants
use DerivedType
implicit none

character*20 char
character*50, allocatable :: filename(:)
logical flag
integer i, maxNum

flag=.FALSE.

!read in number of materials
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='numMaterials') then
		read(81,*) numMaterials
		flag=.TRUE.
	end if
end do
flag=.FALSE.

!Allocate all of the counters for the number of reactions, etc...
allocate(numSingleForm(numMaterials))
allocate(numSingleDiff(numMaterials))
allocate(numFuncDiff(numMaterials))
allocate(numSingleBind(numMaterials))
allocate(numFuncBind(numMaterials))

allocate(numDiffReac(numMaterials))
allocate(numClusterReac(numMaterials))
allocate(numSinkReac(numMaterials))
allocate(numImplantReac(numMaterials))
allocate(numDissocReac(numMaterials))
allocate(numImpurityReac(numMaterials))

allocate(filename(numMaterials))

!Figure out how big to make all of the lists of allowed reactions, etc

do i=1,numMaterials
	!read in filename of mesh file
	do while (flag .eqv. .FALSE.)
		read(81,*) char
		if(char=='materialFile') then
			read(81,*) filename(i)
			flag=.TRUE.
		end if
	end do
	flag=.FALSE.
	
	call readReactionListSizes(filename(i)) !many xx_Defects.txt files

end do

!Allocate all lists of binding, diffusion, and reactions
maxNum=0
do i=1,numMaterials
	if(numSingleForm(i) > maxNum) then
		maxNum=numSingleForm(i)
	end if
end do
allocate(FormSingle(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numSingleDiff(i) > maxNum) then
		maxNum=numSingleDiff(i)
	end if
end do
allocate(DiffSingle(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numFuncDiff(i) > maxNum) then
		maxNum=numFuncDiff(i)
	end if
end do
allocate(DiffFunc(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numSingleBind(i) > maxNum) then
		maxNum=numSingleBind(i)
	end if
end do
allocate(BindSingle(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numFuncBind(i) > maxNum) then
		maxNum=numFuncBind(i)
	end if
end do
allocate(BindFunc(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numDiffReac(i) > maxNum) then
		maxNum=numDiffReac(i)
	end if
end do
allocate(DiffReactions(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numClusterReac(i) > maxNum) then
		maxNum=numClusterReac(i)
	endif
end do
allocate(ClusterReactions(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numImplantReac(i) > maxNum) then
		maxNum=numImplantReac(i)
	end if
end do
allocate(ImplantReactions(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numImpurityReac(i) > maxNum) then
		maxNum=numImpurityReac(i)
	end if
end do
allocate(ImpurityReactions(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numSinkReac(i) > maxNum) then
		maxNum=numSinkReac(i)
	end if
end do
allocate(SinkReactions(maxNum,numMaterials))

maxNum=0
do i=1,numMaterials
	if(numDissocReac(i) > maxNum) then
		maxNum=numDissocReac(i)
	end if
end do
allocate(DissocReactions(maxNum,numMaterials))

do i=1,numMaterials
	!these subroutines (located in MaterialInput.f90) read in material parameters.
	call readMaterialInput(filename(i))
end do

end subroutine

!***************************************************************************************************
!> Subroutine readParameters() - reads in simulation parameters from parameters.txt
!!
!! This subroutine reads in all simulation and material parameters located in parameters.txt
!! as well a the file names for all other input files (material input, mesh, cascades, implantation
!! profile, etc). It also reads in toggles for various simulation options. Default values for
!! several options are stored here.
!!
!! Geometric constants used in computing clustering rates are computed at the end of this subroutine.
!
!***************************************************************************************************
subroutine readParameters()
use mod_constants
use DerivedType
implicit none

character*20 char
logical flag, flag2
integer procVol, volume

!Set default values for variables
test3			='no'
tempStore		=273d0
CuContent		=0.5d-2
numVac			=0
dpaRate			=1d-4
totalDPA		=1d-1
firr			=1d0
atomSize		=0d0
burgers			=0.287d0
reactionRadius	=0.65d0
lattice			=0.2876d0	!Fe
alpha_v			=1d0
alpha_i			=1d0

agingTime       =0d0	!2019.04.30 Add

annealTemp		=273d0
annealTime		=0d0
annealSteps		=0
annealType		='add'
annealTempInc	=0d0

grainBoundaryToggle	='no'
pointDefectToggle	='no'
polycrystal			='no'
singleElemKMC		='no'
sinkEffSearch		='no'	!< This toggle is mostly legacy code and should be set to ’no’
SIAPinMin			=1
meanFreePath		=330000
dislocationDensity	=0d0
impurityDensity		=0d0
max3DInt			=4
cascadeVolume		=0d0
numSims				=1
numGrains			=1
cascadeReactionLimit=100d0

!Toggles for various output types
totdatToggle		='yes'
rawdatToggle		='no'
vtkToggle			='no'
outputDebug			='no'
profileToggle		='no'

minSCluster = 10
minVoid = 10
minLoop = 10
minSV = 10

!Read variables in from file
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='start') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	flag2=.FALSE.
	do while(flag2 .eqv. .FALSE.)
		read(81,*) char
		if(char=='end') then
			flag2=.TRUE.
			flag=.TRUE.
		else if(char=='test3') then
			flag2=.TRUE.
			read(81,*) test3
		else if(char=='temperature') then
			flag2=.TRUE.
			read(81,*) tempStore
		else if(char=='CuContent') then
			flag2=.TRUE.
			read(81,*) CuContent
		else if(char=='numVac') then
			flag2=.TRUE.
			read(81,*) numVac
		else if(char=='dpaRate') then
			flag2=.TRUE.
			read(81,*) dpaRate
		else if(char=='totalDPA') then
			flag2=.TRUE.
			read(81,*) totalDPA
		else if(char=='firr') then
			flag2=.TRUE.
			read(81,*) firr
		else if(char=='atomSize') then
			flag2=.TRUE.
			read(81,*) atomSize
		else if(char=='burgers') then
			flag2=.TRUE.
			read(81,*) burgers
		else if(char=='reactionRadius') then
			flag2=.TRUE.
			read(81,*) reactionRadius
		else if(char=='lattice') then
			flag2=.TRUE.
			read(81,*) lattice
		else if(char=='annealTemp') then
			flag2=.TRUE.
			read(81,*) annealTemp
		else if(char=='annealSteps') then
			flag2=.TRUE.
			read(81,*) annealSteps
		else if(char=='agingTime') then		!2019.04.30 Add
			flag2=.TRUE.
			read(81,*) agingTime
		else if(char=='annealTime') then
			flag2=.TRUE.
			read(81,*) annealTime
		else if(char=='annealType') then
			flag2=.TRUE.
			read(81,*) annealType
		else if(char=='annealTempInc') then
			flag2=.TRUE.
			read(81,*) annealTempInc
		else if(char=='grainBoundaries') then
			flag2=.TRUE.
			read(81,*) grainBoundaryToggle
		else if(char=='pointDefect') then
			flag2=.TRUE.
			read(81,*) pointDefectToggle
		else if(char=='grainSize') then
			flag2=.TRUE.
			read(81,*) meanFreePath
		else if(char=='dislocDensity') then
			flag2=.TRUE.
			read(81,*) dislocationDensity
		else if(char=='impurityConc') then
			flag2=.TRUE.
			read(81,*) impurityDensity
		else if(char=='max3DInt') then
			flag2=.TRUE.
			read(81,*) max3DInt
		else if(char=='cascadeVolume') then
			flag2=.TRUE.
			read(81,*) cascadeVolume
		else if(char=='cascRxnLimit') then
			flag2=.TRUE.
			read(81,*) cascadeReactionLimit
		else if(char=='SIAPinMin') then
			flag2=.TRUE.
			read(81,*) SIAPinMin
		else if(char=='numSims') then
			flag2=.TRUE.
			read(81,*) numSims
		else if(char=='polycrystal') then
			flag2=.TRUE.
			read(81,*) polycrystal
		else if(char=='numGrains') then
			flag2=.TRUE.
			read(81,*) numGrains
		else if(char=='singleElemKMC') then
			flag2=.TRUE.
			read(81,*) singleElemKMC
		else if(char=='sinkEffSearch') then
			flag2=.TRUE.
			read(81,*) sinkEffSearch
		else if(char=='alpha_v') then
			flag2=.TRUE.
			read(81,*) alpha_v
		else if(char=='alpha_i') then
			flag2=.TRUE.
			read(81,*) alpha_i
		else if(char=='conc_v') then
			flag2=.TRUE.
			read(81,*) conc_v
		else if(char=='conc_i') then
			flag2=.TRUE.
			read(81,*) conc_i
		else
			write(*,*) 'error readParameters() unrecognized parameter: ', char
		end if
	end do
	flag2=.FALSE.
end do
flag=.FALSE.

!***********************************************************************
!Output parameters
!***********************************************************************
do while(flag .eqv. .FALSE.)
	read(81,*) char
	if(char=='OutputStart') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	flag2=.FALSE.
	do while(flag2 .eqv. .FALSE.)
		read(81,*) char
		if(char=='end') then
			flag2=.TRUE.
			flag=.TRUE.
		else if(char=='vtkToggle') then
			flag2=.TRUE.
			read(81,*) vtkToggle
		else if(char=='restartToggle') then
			flag2=.TRUE.
			read(81,*) outputDebug
		else if(char=='totdatToggle') then
			flag2=.TRUE.
			read(81,*) totdatToggle
		else if(char=='rawdatToggle') then
			flag2=.TRUE.
			read(81,*) rawdatToggle
		else if(char=='profileToggle') then
			flag2=.TRUE.
			read(81,*) profileToggle
		else if(char=='minSCluster') then
			flag2=.TRUE.
			read(81,*) minSCluster
		else if(char=='minVoid') then
			flag2=.TRUE.
			read(81,*) minVoid
		else if(char=='minLoop') then
			flag2=.TRUE.
			read(81,*) minLoop
		else if(char=='minSV') then
			flag2=.TRUE.
			read(81,*) minSV
		else
			write(*,*) 'error readParameters() unrecognized parameter: '
		end if
	end do
	flag2=.FALSE.
end do
flag=.FALSE.


!***********************************************************************
!if we are using adaptive meshing, read in the adaptive meshing parameters
!***********************************************************************
if(meshingType=='adaptive') then
	flag=.FALSE.
	
	do while(flag .eqv. .FALSE.)
		read(81,*) char
		if(char=='fineStart') then
			flag=.TRUE.
		endif
	end do
	flag=.FALSE.
	
	do while(flag .eqv. .FALSE.)
		flag2=.FALSE.
		do while(flag2 .eqv. .FALSE.)
			read(81,*) char
			if(char=='end') then
				flag2=.TRUE.
				flag=.TRUE.
			else if(char=='fineLength') then
				flag2=.TRUE.
				read(81,*) fineLength
			else if(char=='numxFine') then
				flag2=.TRUE.
				read(81,*) numxCascade
			else if(char=='numyFine') then
				flag2=.TRUE.
				read(81,*) numyCascade
			else if(char=='numzFine') then
				flag2=.TRUE.
				read(81,*) numzCascade
			else
				write(*,*) 'error readParameters() unrecognized parameter'
			end if
		end do
		flag2=.FALSE.
	end do
	flag=.FALSE.
	
	cascadeElementVol=fineLength**3d0
	numCellsCascade=numxCascade*numyCascade*numzCascade
endif

!***********************************************************************
!clustering rate constants
!***********************************************************************

omega=(48d0*pi**2/atomSize**2)**(1d0/3d0) 			!clustering rate parameter for spherical clusters
omegastar=(4*pi*reactionRadius)/atomSize			!clustering rate parameter modifier due to reaction radius
omega2D=(4d0*pi/(atomSize*burgers))**(1d0/2d0)		!clustering rate parameter for 1D migrating circular clusters
omega1D=(9d0*pi/(16d0*atomSize))**(1d0/6d0)			!clustering rate parameter for 1D migrating spherical clusters
omegastar1D=reactionRadius*(pi/atomSize)**(1d0/2d0)
!omegastar1D=0d0									!clustering rate parameter modifier due to reaction radius
omegacircle1D=(1d0/burgers)**(1d0/2d0)				!clustering rate parameter for 1D migrating circular clusters

recombinationCoeff=4d0*pi*(.4466)/atomSize			!from Stoller et al., not used any longer

if(myProc%taskid==MASTER) write(*,*) 'cascadeReactionLimit', cascadeReactionLimit

end subroutine


!***************************************************************************************************
!>Subroutine reaction list sizes - finds max sizes of reaction parameters for allocation
!!
!!Information read in includes:
!!
!!1) Number of allowed defects
!!
!!2) Number of allowed reactions of each size
!***************************************************************************************************
subroutine readReactionListSizes(filename)	!< filename is 'xx_Defects.txt'
use DerivedType
use mod_constants
implicit none

integer i, j, count
character*20 :: char
character*50 :: filename
integer, allocatable :: DefectType(:), productType(:)
!type(reaction), pointer :: reactions, reactionCurrent
logical flag
Double precision Diff, Eb
integer matNum

open(80, file=filename,action='read', status='old')

flag=.FALSE.

!The following is for the entire parameter set

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='material') then
		flag=.TRUE.
		read(80,*) matNum	!< matNum = 1 or 2
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='species') then	
		flag=.TRUE.
		read(80,*) numSpecies	!< numSpecies = 4
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleForm(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='diffusionPrefactors') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleDiff(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numFunction') then
		flag=.TRUE.
		read(80,*) numFuncDiff(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='bindingEnergies') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numSingle') then
		flag=.TRUE.
		read(80,*) numSingleBind(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='numFunction') then
		flag=.TRUE.
		read(80,*) numFuncBind(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='singleDefect') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='dissociation') then
		flag=.TRUE.
		read(80,*) numDissocReac(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='diffusion') then
		flag=.TRUE.
		read(80,*) numDiffReac(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='sinkRemoval') then
		flag=.TRUE.
		read(80,*) numSinkReac(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='impurityTrapping') then
		flag=.TRUE.
		read(80,*) numImpurityReac(matNum)
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='multipleDefect') then
		flag=.TRUE.
	end if
end do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='clustering') then
		flag=.TRUE.
		read(80,*) numClusterReac(matNum)
	end if
end  do
flag=.FALSE.

do while(flag .eqv. .FALSE.)
	read(80,*) char
	if(char=='noDefect') then
		flag=.TRUE.
		read(80,*) numImplantReac(matNum)
	end if
end do
flag=.FALSE.

close(80)
end subroutine
