#' @title Import TPP-TR datasets for analysis by the 
#'   \code{\link{TPP}} package.
#'   
#'   
#' @description \code{tpptrImport} imports several tables of protein fold changes and 
#' stores them in a list of ExpressionSets for use in the \code{\link{TPP}} package.
#'   
#' @details The imported datasets have to contain measurements obtained by 
#'  TPP-TR experiments. Fold changes need to be pre-computed
#'   using the lowest temperature as reference.
#'   
#'   An arbitrary number of datasets can be specified by filename in the 
#'   \code{Path}-column of the \code{configTable} argument, or given directly as
#'   a list of dataframes in the \code{data} argument. They can differ, 
#'   for example, by biological replicate or by experimental condition (for 
#'   example, treatment versus vehicle). Their names are defined uniquely by the
#'   \code{Experiment} column in \code{configTable}. If this argument is not 
#'   specified, generic names will be assigned. Replicates and experimental 
#'   conditions can be specified by optional columns in \code{configTable}.
#'   
#'   The default settings are adjusted to analyse data of the pyhton package 
#'   \code{isobarQuant}. You can also customise them for your own dataset.
#'   
#'   The \code{configTable} argument is a dataframe, or the path to a 
#'   spreadsheet (tab-delimited text-file or xlsx format). Information about 
#'   each experiment is stored row-wise. It contains the following columns: 
#'   \itemize{
#'  \item{\code{Path}:}{location of each datafile. Alternatively, data can be directly handed
#'   over by the \code{data} argument.}
#'  \item{\code{Experiment}: }{unique experiment names.}
#'  \item{\code{Condition}: }{experimental conditions of each dataset.}
#'  \item{\code{Replicate}:}{experimental replicates of each dataset.}
#'  \item{Label columns: } each isobaric label names a column that contains the 
#'   temperatures administered for the label in the individual experiments.
#' }
#'   
#'   Proteins with NAs in the data column specified by \code{idVar} receive 
#'   unique generic IDs so that they can be processed by the package.
#'   
#' @param configTable either a dataframe or the path to a spreadsheet. In both cases
#' it specifies necessary information of the TPP-CCR experiment.
#' @param data single dataframe, or list of dataframes, containing fold 
#'   change measurements and additional annotation columns to be imported. Can 
#'   be used instead of specifying the file path in \code{configTable}.
#' @param idVar character string indicating which data column provides the unique 
#' identifiers for each protein.
#' @param fcStr character string indicating which columns contain the actual 
#'   fold change values. Those column names containing the suffix 
#'   \code{fcStr} will be regarded as containing fold change values.
#' @param naStrs character vector indicating missing values in the data table. 
#'   When reading data from file, this value will be passed on to the argument 
#'   \code{na.strings} in function \code{read.delim}.
#' @param qualColName character string indicating which column can be used for 
#'   additional quality criteria when deciding between different non-unique 
#'   protein identifiers.
#' @return A list of ExpressionSets storing data for each treatment condition 
#'   and biological replicate. Each ExpressionSet contains the measured fold 
#'   changes, as well as row and column metadata. In each ExpressionSet 
#'   \code{S}, the fold changes can be accessed by \code{exprs(S)}. Protein 
#'   expNames can be accessed by \code{featureNames(S)}. TMT labels and the 
#'   corresponding temperatures are returned by \code{S$labels} and 
#'   \code{S$temperatures}.
#'   
#' @export
#' @seealso \code{\link{tppccrImport}}, \code{\link{importSingleExp}}

tpptrImport <- function(configTable, data=NULL, idVar="gene_name", 
                        fcStr="rel_fc_", naStrs=c("NA", "n/d", "NaN"), qualColName="qupm"){
  message("Importing data...\n")
  configTable <- importCheckConfigTable(infoTable=configTable)
  
  expNames <- configTable$Experiment
  expCond  <- configTable$Condition
  expRepl  <- configTable$Replicate
  files    <- configTable$Path
  labels   <- setdiff(colnames(configTable), c("Experiment", "Condition", "Replicate", "Path"))
  temperatures <- configTable[, labels]
  
  ## Determine names of datasets
  if (is.data.frame(data)){
    nData <- 1
  } else {
    nData <- max(length(data), length(files))    
  }
  expNameCheck    <- importCheckExperimentNames(expNames=expNames, expectedLength=nData)
  expNames        <- expNameCheck$expNames
  genericExpNames <- expNameCheck$genericExpNames
  
  ## Check whether dataframes or filenames are specified for data import:
  argList <- importCheckDataFormat(dataframes=data, files=files, expNames=expNames, genericExpNames=genericExpNames)
  data <- argList[["dataframes"]]
  files      <- argList[["files"]]
    
  ## Determine matrix of concentrations to each isotope label
  tempMatrix <- importCheckTemperatures(temp=temperatures, nData=nData)
  
  ## Check isotope label argument
  labels <- importCheckLabels(labelValues=labels, temperatureMat=tempMatrix)
  
  ## Check format of condition and replicate vectors:
  expRepl <- importCheckReplicates(repInfo=expRepl, expectedLength=nData)
  expCond <- importCheckConditions(condInfo=expCond, expectedLength=nData)
    
  ## Import tables, convert into ExpressionSet format, and store in list:
  fcListAll <- sapply(1:length(expNames), simplify=FALSE, USE.NAMES = FALSE,
                      function(i){importSingleExp(filename     = files[[i]],
                                                  dataframe    = data[[expNames[i]]],
                                                  labels       = labels,
                                                  labelValues  = tempMatrix[i,],
                                                  name         = expNames[i],
                                                  condition    = expCond[i],
                                                  replicate    = expRepl[i],
                                                  idVar        = idVar,
                                                  fcStr        = fcStr,
                                                  qualColName  = qualColName,
                                                  naStrs       = naStrs,
                                                  type         = "TR")})
  names(fcListAll) <- expNames
  message("\n")
  
  return(fcListAll)
}