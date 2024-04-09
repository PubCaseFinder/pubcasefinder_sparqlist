# [PCF] FILTER: GET GENE IDs by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0020341
  * example: 0018096, 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

#SELECT DISTINCT *
SELECT DISTINCT STR(?mondo) as ?mondo ?count
#SELECT STR(?mondo) as ?mondo COUNT(DISTINCT ?gene) as ?count
#SELECT COUNT(DISTINCT ?gene) as ?count
#SELECT DISTINCT ?mondo_sup_tier ?gene
#SELECT DISTINCT ?mondo_sup_tier COUNT(DISTINCT ?gene) as ?count
#SELECT DISTINCT ?mondo_sup_tier ?gene

WHERE {
  {
    SELECT DISTINCT ?mondo_sup_tier WHERE {
      mondo:MONDO_{{mondo_id_list}} rdfs:subClassOf* ?mondo_sup_tier .      
      FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
    }
  }
  
#  {
#    SELECT DISTINCT ?mondo_sup_tier ?disease WHERE {
#      ?mondo_sub_tier rdfs:subClassOf* ?mondo_sup_tier ;
#                      skos:exactMatch ?exactMatch_disease .
#      FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
#      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
#      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
#    }
#  }
#  ?disease rdf:type ncit:C7057 .
#  ?gene rdf:type ncit:C16612 .
#  ?as sio:SIO_000628 ?disease ;
#      sio:SIO_000628 ?gene .
#  ?mondo_sup_tier <http://www.geneontology.org/formats/oboInOwl#id> ?mondo .
  
#  {
#    SELECT DISTINCT ?mondo_sup_tier COUNT(DISTINCT ?gene) as ?count WHERE {
#      ?mondo_sub_tier rdfs:subClassOf* ?mondo_sup_tier ;
#                      skos:exactMatch ?exactMatch_disease .
#      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
#      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
#      ?disease rdf:type ncit:C7057 .
#      ?gene rdf:type ncit:C16612 .
#      ?as sio:SIO_000628 ?disease ;
#          sio:SIO_000628 ?gene .
#    }
#  }
  ?mondo_sup_tier sio:SIO_001112 ?count .
  FILTER(DATATYPE(?count) = xsd:integer).
  ?mondo_sup_tier <http://www.geneontology.org/formats/oboInOwl#id> ?mondo .
} order by DESC(?count)
```

## Output
```javascript
({mondo_id_list, result})=>{ 
  var rows = result.results.bindings;
  var list = []
  var min = 9999;
  var temp = 0;
  
  for (let i = 0; i < rows.length; i++) {
    if (0 != parseInt(rows[i].count.value) && 
        200 <= parseInt(rows[i].count.value))
    {
      min = rows[i].count.value;
      temp = i;
    }
  }
  list.push(rows[temp].mondo.value);
  //return list + " " + min
  
  return list
  
//  console.log("min : " + min, "row : " + temp)
//  list.push(rows[0].mondo.value);
//	return list
/*  
  if(rows){
    //dic['MONDO:' + mondo_id_list] = list;
    dic[mondo_id_list] = list;
  }
  return dic
*/  
}