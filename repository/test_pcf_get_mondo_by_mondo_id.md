# [PCF] FILTER: GET MONDO by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0017103
  * example: 0017103, 0016054, 0002320, 0020022, 0019755

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  //mondo_id = mondo_id.replace(/MONDO:/g,"")
  mondo_id = mondo_id.replace(/,/g," ").replace(/MONDO:/g,"")
   if (mondo_id.match(/[^\s]/))  return mondo_id.split(/\s+/);
  return false;
  //return mondo_id;
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

#SELECT COUNT(DISTINCT ?gene_id)
SELECT DISTINCT ?gene_id

WHERE {
  #mondo:MONDO_{{mondo_id_list}} <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
#  SELECT DISTINCT ?disease WHERE {
#    {
      {{#if mondo_id_list}}
        VALUES ?mon { {{#each mondo_id_list}} mondo:MONDO_{{this}} {{/each}} }
      {{/if}}
      #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
      ?mondo_sub_tier rdfs:subClassOf* ?mon ;
                      skos:exactMatch ?exactMatch_disease .
      
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
#    }
#  }
    ?as sio:SIO_000628 ?disease ;
        sio:SIO_000628 ?gene .
    ?disease rdf:type ncit:C7057 .
    ?gene rdf:type ncit:C16612 ;
          dcterms:identifier ?gene_id . 
}
```

## Output
```javascript
({mondo_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;

  for (let i = 0; i < rows.length; i++) {
    list.push('GENEID:' + rows[i].gene_id.value);
  }
  
  if(rows){
    dic['MONDO:' + mondo_id_list] = list;
  }

  return dic
}