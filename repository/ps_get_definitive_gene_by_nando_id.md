# [PCF] FILTER: GET Definitive GENE by NANDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200021
  * example: 1200021, 1200220, 1200477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql/

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/gi,"").replace(/[\s,]/g," ")
   if (nando_id.match(/[^\s]/)) return nando_id.split(/\s+/);
  return false;
  //return mondo_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
SELECT 
?ncbi_gene_id
?hgnc_gene_symbol
WHERE {
  ?an sio:SIO_000628 nando:{{nando_id_list}} ;
      sio:SIO_000628 ?ncbi_gene_url .
  ?ncbi_gene_url rdf:type ncit:C16612 ;
                 dcterms:identifier ?ncbi_gene_id ;
                 sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
}
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```