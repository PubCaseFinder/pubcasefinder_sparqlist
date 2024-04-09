# [PCF] Get GENE tooltip data by NCBI GENE ID - https://integbio.jp/togosite/sparql
## Parameters
* `ncbi_gene_id` NCBI GENE ID
  * default: 1723
  * example: 1723, 9723, 55636, 157570, 10262, 2260, 4038, 5144, 9469, 324

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) => {
  ncbi_gene_id = ncbi_gene_id.replace(/GENEID:/g,"")
  return ncbi_gene_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX nuc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
PREFIX hop: <http://purl.org/net/orthordf/hOP/ontology#>

SELECT DISTINCT
str(?hgnc_gene_symbol) as ?hgnc_gene_symbol
str(?type_of_gene) as ?type_of_gene
str(?location) as ?location
str(?full_name) as ?full_name
str(?other_full_name) as ?other_full_name
str(?synonym) as ?synonym
str(?ncbi_gene_summary) as ?ncbi_gene_summary
str(?ncbi_gene_url) as ?ncbi_gene_url
str(?hgnc_gene_url) as ?hgnc_gene_url

WHERE {
  VALUES ?ncbi_gene_url { ncbigene:{{ncbi_gene_id_list}} }
  
  OPTIONAL { ?ncbi_gene_url dcterms:description ?full_name . } 
  OPTIONAL { ?ncbi_gene_url dcterms:alternative ?other_full_name . }
  OPTIONAL { ?ncbi_gene_url nuc:gene_synonym ?synonym . }
  OPTIONAL { ?ncbi_gene_url nuc:map ?location . } 
  OPTIONAL { ?ncbi_gene_url hop:typeOfGene ?type_of_gene . } 
  OPTIONAL { ?ncbi_gene_url sio:SIO_000205 ?hgnc_gene_url . }
  OPTIONAL { ?ncbi_gene_url obo:NCIT_C42581 ?ncbi_gene_summary . }
  OPTIONAL { ?hgnc_gene_url rdfs:label ?hgnc_gene_symbol . }  
  
#  OPTIONAL { ?ncbi_gene_url dcterms:description ?full_name ;
#                            dcterms:alternative ?other_full_name ;
#                            nuc:standard_name ?hgnc_gene_symbol ;
#                            nuc:gene_synonym ?synonym ;
#                            nuc:map ?location ;
#                            hop:typeOfGene ?type_of_gene ;
#                            sio:SIO_000205 ?hgnc_gene_url .
#           } 
}
```

## Output
```javascript
({result})=>{ 
  var dic = {}
  var rows = result.results.bindings;
  
  dic['hgnc_gene_symbol'] = {}
  dic['type_of_gene'] = {}
  dic['location'] = {}
  dic['full_name'] = {}
  dic['ncbi_gene_url'] = {}
  dic['hgnc_gene_url'] = {}
  dic['ncbi_gene_summary'] = {}
  dic['other_full_name'] = new Set()
  dic['synonym'] = new Set()

  for (let i = 0; i < rows.length; i++) {
    if (rows[i].hgnc_gene_symbol) { 
        dic['hgnc_gene_symbol'] = rows[i].hgnc_gene_symbol.value
     }
    if (rows[i].type_of_gene) { 
        dic['type_of_gene'] = rows[i].type_of_gene.value
     }
    if (rows[i].location) { 
        dic['location'] = rows[i].location.value
     }
    if (rows[i].full_name) { 
        dic['full_name'] = rows[i].full_name.value
     }
    if (rows[i].ncbi_gene_summary) { 
        dic['ncbi_gene_summary'] = rows[i].ncbi_gene_summary.value
     }
    if (rows[i].synonym) { 
        dic['synonym'].add(rows[i].synonym.value)
     }
    if (rows[i].other_full_name) { 
        dic['other_full_name'].add(rows[i].other_full_name.value)
     }
    if (rows[i].ncbi_gene_url) { 
        dic['ncbi_gene_url'] = rows[i].ncbi_gene_url.value
     }
    if (rows[i].hgnc_gene_url) { 
        dic['hgnc_gene_url'] = rows[i].hgnc_gene_url.value
     }
  }
  
  dic['synonym'] = Array.from(dic['synonym'])
  dic['other_full_name'] = Array.from(dic['other_full_name'])
  
  return dic
}
```