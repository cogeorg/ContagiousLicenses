// ============================================================================
//
// Pypi -- 1.6.0
//
// ============================================================================
// cd ~/Dropbox/Papers/00_Ideas/ContagiousLicenses/Pypi/
cd ~/Downloads/Pypi/

//
// PREPARATIONS
//
{
// repositories 
insheet using repositories_Pypi.csv, delimiter(";") names clear
	drop if repoid=="RepoID"
	destring repoid, replace
	destring size, replace
	drop if size == 0
	destring numstars, replace
	destring numforks, replace
	destring numwatchers, replace
	destring numcontributors, replace
	
	gen double createdtime=clock( substr(createdtimestamp,1,19), "YMDhms")
	format createdtime %tc
	
	gen double lastsyncedtime=clock( substr(lastsyncedtimestamp,1,19), "YMDhms")
	format lastsyncedtime %tc
save repositories_Pypi.dta, replace

// projects
insheet using "projects_Pypi.csv", delimiter(";") names clear
	rename projectid id 
	rename repositoryid repoid
save "projects_Pypi.dta", replace
	rename id projectid
	keep projectid repoid	
	drop if repoid == .
	duplicates drop
save projectid_repoid.dta, replace 

// versions
insheet using versions_Pypi.csv, delimiter(";") names clear
save versions_Pypi.dta, replace
}


//
// CUTS -- PART A -- COVARIATE-BASED CUTS
// NOTE: RUN THIS BEFORE 15_match_repositories.py
//
{
use versions_Pypi.dta, clear
// first merge repoids
merge m:1 projectid using projectid_repoid.dta
	keep if _merge == 3
	drop _merge
	bysort repoid: gen num_versions = _N
	
	drop versionnumber publishedtimestamp
	
	duplicates drop  // NOTE: not unique on repoid, some repoids have multiple projectids with different projectnames
	
// then merge repo-based covariates
merge m:1 repoid using repositories_Pypi.dta
	// repositories that exist in master but not in using are typically projects in other programming
	// languages (managed by Pypi), i.e. this is the first cut
	keep if _merge == 3  
	drop _merge 
	
	// apply additional cuts
	su size, d 
	scalar p5_size = r(p5)  // small projects could be hobbyists, we focus on more professional developers
	drop if size < p5_size
	
	drop if numstars <= 2
	drop if description == ""
	su numstars, d
	scalar p95_numstars = r(p95)
	drop if numstars >= p95_numstars
save covariates_Pypi-cuts.dta, replace
	keep repoid
	duplicates drop
save repoid-cuts.dta, replace
outsheet using repoid-cuts.csv, delimiter(";") nonames replace

// apply cuts to project mapping
use projectid_repoid.dta, clear
merge m:1 repoid using repoid-cuts.dta 
	keep if _merge == 3
	drop _merge 
save projectid_repoid-cuts.dta, replace 
outsheet using projectid_repoid-cuts.csv, delimiter(";") replace
// NOTE: Cuts have been applied to both sides
}  // now run 15_match_repositories.py, 30_create_dependency_graph.py, and 80_analyze_graph.py


//
// CUTS -- PART B -- NETWORK-BASED CUTS
// NOTE: RUN THIS AFTER 30_create_dependency_graph.py and 80_analyze_graph.py
// CREATE CONSECUTIVE IDs
{
insheet using repo_dependencies_Pypi-cuts-nodes-lcc.csv, delimiter(";") names clear
	sort repoid
	gen id_repo_new = _n  // based on LCC constructed *AFTER* covariate cuts were applied
save repo_dependencies_Pypi-cuts-repoid-lcc.dta, replace

insheet using repo_dependencies_Pypi-cuts-lcc.csv, delimiter(";") names clear
	rename v1 from_repo 
	rename v2 to_repo
save repo_dependencies_Pypi-cuts-lcc.dta, replace
}

//
// COVARIATE MASTER DATASET
//
{
use covariates_Pypi-cuts, clear	
	// APPLY NETWORK-BASED CUTS AS WELL
merge m:1 repoid using repo_dependencies_Pypi-cuts-repoid-lcc.dta 
	drop id_repo_new
	keep if _merge == 3
	drop _merge

	drop project* 
	duplicates drop
	
	gen created = substr(createdtimestamp, 1, 10)
	gen created_date = date(created, "YMD")
	drop created
	gen reference_date = mdy(1, 13, 2020)
	gen maturity = reference_date - created_date
	format created_date %td
	
	order repoid
	
	// merge new repo ids
merge m:1 repoid using repo_dependencies_Pypi-cuts-repoid-lcc.dta
	keep if _merge == 3
	drop _merge
	
save master_Pypi-cuts-lcc.dta, replace
outsheet using master_Pypi-cuts-lcc.csv, delimiter(";") replace
}

