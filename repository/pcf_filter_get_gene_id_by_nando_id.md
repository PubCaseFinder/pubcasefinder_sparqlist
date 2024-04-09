# [PCF] FILTER: GET GENE IDs by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 2100004
  * examples: 1200009, 2200865
  
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  return nando_id;
}
```

## `result`
```sparql
PREFIX : <http://nanbyodata.jp/ontology/nando#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
SELECT DISTINCT ?gene_id
WHERE {
  {
    SELECT DISTINCT ?disease WHERE {
      ?nando a owl:Class ;
             dcterms:identifier "NANDO:{{nando_id_list}}" .
      ?nando_sub_tier rdfs:subClassOf* ?nando ;
                      skos:closeMatch ?mondo .
      ?mondo skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
    }  
  }
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/pcf> {
    ?ass sio:SIO_000628 ?disease ;
         sio:SIO_000628 ?gene_uri .
	?disease rdf:type ncit:C7057 .
    ?gene_uri rdf:type ncit:C16612 ;
              dcterms:identifier ?gene_id . 
    ?gene_uri sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
  }
}
order by ?hgnc_gene_symbol
```

## Output
```javascript
({nando_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;

  for (let i = 0; i < rows.length; i++) {
    list.push('GENEID:' + rows[i].gene_id.value);
  }

  if(rows){
    dic['NANDO:' + nando_id_list] = list;
  }
  
  return dic
}