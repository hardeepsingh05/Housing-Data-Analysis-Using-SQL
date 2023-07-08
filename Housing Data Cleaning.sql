/*
This project includes the Data Exploration, Data Manipulation and a bit of Pre-Processing of a dataset from a Real Estate Company.
Let's get started
*/


-- Defining the name of the Database in which our Dataset is imported
Use Portfolio;

/*
Let's first of all explore this dataset a bit
*/
-- Our Dataset name is "HousingData". This dataset is related to the real estate market of a specific city "Nashville" and we have data column related to the house's 'ParcelID','LandSize','No. of Bedrooms' etc. 
-- Let's see what we can obtain from this "Housing Dataset"

SELECT 
    *
FROM
    housingdata;

    
-- Checking the format of all the Columns/Attributes in Dataset
describe housingdata;
 
 -- Let's Check the distinct 'Landuse' WRT to the Houses
SELECT DISTINCT
    Landuse, COUNT(Landuse) AS Count
FROM
    Housingdata
GROUP BY LandUse
ORDER BY Count DESC;

-- So, we can see 'Single Family' and 'Residential Condo' are mostly available

SELECT 
    UniqueId,
    LandUse,
    SaleDate,
    SalePrice,
    propertyAddress,
    PropertyCity,
    Acreage,
    OwnerName,
    TotalValue,
    YearBuilt
FROM
    Housingdata
ORDER BY SalePrice DESC
LIMIT 10;

SELECT 
    UniqueId,
    LandUse,
    SaleDate,
    SalePrice,
    propertyAddress,
    PropertyCity,
    Acreage,
    OwnerName,
    TotalValue,
    YearBuilt
FROM
    Housingdata
ORDER BY TotalValue DESC
LIMIT 10;

SELECT 
    UniqueId,
    LandUse,
    SaleDate,
    SalePrice,
    propertyAddress,
    PropertyCity,
    Acreage,
    OwnerName,
    TotalValue,
    YearBuilt
FROM
    Housingdata
ORDER BY Acreage DESC
LIMIT 10;


-- Let's Check the distinct 'ExteriorWall' WRT to the Houses
SELECT DISTINCT
    ExteriorWall, COUNT(ExteriorWall) AS Count
FROM
    Housingdata
GROUP BY ExteriorWall
ORDER BY Count DESC;

-- Check the Top 10 old Houses WRT to built
SELECT 
    *
FROM
    HousingData
ORDER BY YearBuilt DESC
LIMIT 10;

-- Let's see the houses which are having more number of the Bathrooms and Bedrooms;
SELECT 
    *
FROM
    Housingdata
ORDER BY Bedrooms DESC
LIMIT 10;
  
-- Let's Check the distinct 'FoundationType' WRT to the Houses
SELECT DISTINCT
    FoundationType, COUNT(FoundationType) AS Count
FROM
    Housingdata
GROUP BY FoundationType
ORDER BY Count DESC;

-- Let us see the houses whose 'SalePrice' is less than their 'BuildingValue' 
SELECT 
    UniqueID,
    ParcelID,
    SaleDate,
    YearBuilt,
    LandUse,
    PropertyAddress,
    PropertyCity,
    TotalValue,
    SalePrice,
    BuildingValue,
    (BuildingValue - SalePrice) AS DifferenceInBuildSale
FROM
    HousingData
WHERE
    SalePrice < BuildingValue
ORDER BY DifferenceInBuildSale DESC
LIMIT 10;

-- Similary we can check the lsit of houses based on difference between their 'TotalValue' and 'SalePrice' according to our Budget
SELECT 
    *
FROM
    housingData; 

-- So, in this way we can get and explore a lot more things out of this Housing Dataset





/* 
Let's see what kind of data preprocessing and manipulation can be done
*/

-- Updating the SaleDate Format and DataType 
UPDATE housingdata 
SET 
    Saledate = STR_TO_DATE(SaleDate, '%d-%m-%Y');
SELECT 
    Saledate
FROM
    housingdata;
    
-- Checking the DataType of the SaleDate Column
SELECT 
    column_name, data_type
FROM
    Information_Schema.columns
WHERE
    Table_name = 'housingdata'
        AND Column_name = 'SaleDate';


-- Populate Property Address Data
SELECT 
    PropertyAddress
FROM
    housingdata;

SELECT 
    COUNT(*)
FROM
    housingData
WHERE
    PropertyAddress IS NULL;                                                           -- Counting the Null values in Property Address

-- We need to fill the Null values in PopertyAddress attribute by syncing with the ParcelID

Set Autocommit = OFF;
Start Transaction;

SELECT 
    A.ParcelID,
    A.PropertyAddress,
    B.ParcelID,
    B.PropertyAddress,
    COALESCE(A.PropertyAddress, B.PropertyAddress)
FROM
    HousingData A
        JOIN
    HousingData B ON A.ParcelID = B.ParcelID
        AND A.UniqueID <> B.UniqueID
WHERE
    A.PropertyAddress IS NULL;

-- Updating the possible null values in the PropertyAddress attribute
UPDATE HousingData A
        JOIN
    HousingData B ON A.ParcelID = B.ParcelID
        AND A.UniqueID <> B.UniqueID 
SET 
    A.PropertyAddress = COALESCE(A.PropertyAddress, B.PropertyAddress)
WHERE
    A.PropertyAddress IS NULL;

/*
Now, Let's try to break the PropertyAddress attribute into individual columns as Address, City
*/

SELECT 
    *
FROM
    HousingData;

SELECT 
    TRIM(SUBSTRING_INDEX(Property_address, ',', 1)) AS Address,
    TRIM(SUBSTRING_INDEX(Property_address, ',', - 1)) AS City
FROM
    HousingData;
    
-- Addiing these Two New Columns to the Dataset

Alter Table HousingData 
Add PropertyAddress varchar(250);

UPDATE HousingData 
SET 
    PropertyAddress = TRIM(SUBSTRING_INDEX(Property_address, ',', 1));

Alter Table HousingData 
Add PropertyCity varchar(250);

UPDATE HousingData 
SET 
    PropertyCity = TRIM(SUBSTRING_INDEX(Property_address, ',', - 1));

/*
Let's deal with the OwnerAddress also in the same way by splitting it up in the three Columns such as Address, State, And City
*/

SELECT 
    OwnerAddress
FROM
    HousingData;-- Checking the Dataset
 
SELECT 
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
                ',',
                1)) AS City,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', - 1)) AS State
FROM
    HousingData;
    
-- Addiing these Three New Columns to the Dataset 

Alter Table HousingData 
Add OwnerAddressNew varchar(250);

UPDATE HousingData 
SET 
    OwnerAddressNew = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));
    
Alter Table HousingData 
Add OwnerCity varchar(250);

UPDATE HousingData 
SET 
    OwnerCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
                ',',
                1));
    
Alter Table HousingData 
Add OwnerState varchar(250);

UPDATE HousingData 
SET 
    OwnerState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', - 1));

SELECT 
    *
FROM
    HousingData;                                                                        -- Checking the Dataset After the update;



/*
--  Change Y and N to 'Yes' and 'No' in 'Sold as Vacant' Column
*/
Use Portfolio;
Select * from Housingdata;
Select Distinct SoldAsVacant, Count(SoldAsVacant) from HousingData group by SoldAsVacant;
Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
     End as Modified
from HousingData;

-- Updating in the main Dataset
UPDATE HousingData 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

Commit; -- Committing the Changes in the Dataset
/*
Remove Duplicates
*/
Start transaction; -- Starting a new Transaction

Select * from HousingData;

With RoWNumCTE AS(                                                                   --  Defining a Common Table Expression for finding Duplicates
Select *, Row_number() over (
partition by ParcelID,
			 propertyaddress,
             SalePrice,
             SaleDate,
             LegalReference,
             OwnerName,
             OwnerAddress
             Order By 
				UniqueID 
                ) as Row_Num
             
from HousingData order by Row_Num desc)

Select Count(*) from RowNumCTE where Row_Num = 2;                                             -- Checking the count of the Duplicate Rows;

Delete from HousingData                                                                       -- Deleting the Duplicated Rows from the Main Dataset 
    where UniqueID in (Select UniqueID from RowNumCTE where Row_Num > 1);
    

Commit;                                                                                     -- Doing Commit

/* 
Deleting Unused Columns from the HousingData
*/

Start Transaction;                                                                         -- Starting new transaction

Select * from HousingData;

Alter Table HousingData                                                                    -- Altering the Table Data 
Drop column TaxDistrict, Drop Column OwnerAddress, Drop Column Property_Address;

Commit;


-- Hence we have done different changes, did Analyzing and Pre-Processing of this Housing data and a lot more things can also be done. 




