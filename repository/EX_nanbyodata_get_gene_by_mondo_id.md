# Get Gene by MONDO ID

## Parameters

* `mondo_id` MONDO ID（複数のIDを入力可能）
  * default: 
  * example: 0007739, 0009688

## Endpoint

https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = 'obo:MONDO_' + mondo_id.replace(/[\s,]+/g," obo:MONDO_")
  return mondo_id;
}
```

## `result` retrieve phenotypes associated with the MONDO ID

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX dcterms: <http://purl.org/dc/terms/>


SELECT DISTINCT
str(?nando_identifier) as ?nando_identifier
str(?hgnc_gene_symbol) as ?hgnc_gene_symbol
WHERE{
  {
    SELECT DISTINCT ?nando ?mondo_id ?nando_identifier ?disease WHERE { 
      ?nando nando:hasNotificationNumber ?nn.
      ?nando dcterms:identifier ?nando_identifier .
      ?nando_sub rdfs:subClassOf* ?nando ;
                 skos:closeMatch ?mondo_id .
      ?mondo_id skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
    }
  }
    ?disease rdf:type ncit:C7057 .
  	?gene rdf:type ncit:C16612 .
    ?as sio:SIO_000628 ?disease ;
        sio:SIO_000628 ?gene .
    ?gene sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
}
order by ?nando_identifier ?hgnc_gene_symbol
```

## `return`
```javascript

({result})=>{ 
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    if (rows[i].nando_identifier.value in dic)
    {
      dic[rows[i].nando_identifier.value].push(rows[i].hgnc_gene_symbol.value);
    }
    else
    {
      dic[rows[i].nando_identifier.value] = [];
      dic[rows[i].nando_identifier.value].push(rows[i].hgnc_gene_symbol.value);
    };
  }

  return dic
};

```
## Description
- 過去のUIで使用していたSPARQListで現在は使われていません。（編集：高月）