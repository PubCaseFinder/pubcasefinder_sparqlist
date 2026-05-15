# [PCF] Get PubChem data by GENE ID - https://pubcasefinder.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0005093
  * example: 0005835, 0004975, 0018096, 0007477
* `ncbi_gene_id` NCBI gene ID
  * default: 1294
  * example: 8517, 488

## Endpoint
https://rdfportal.org/backend/pubchem/sparql

//https://rdfportal.org/pubchem/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) =>
  'mondo:' + mondo_id.replace(/MONDO:/gi, '').trim().replace(/[\s,]+/g, ' mondo:');
```

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) =>
  'ncbigene:' + ncbi_gene_id.replace(/ncbigene:/gi, '').trim().replace(/[\s,]+/g, ' ncbigene:');
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX bao: <http://www.bioassayontology.org/bao#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene:>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
PREFIX pcvocab: <http://rdf.ncbi.nlm.nih.gov/pubchem/vocabulary#>
PREFIX prism: <http://prismstandard.org/namespaces/basic/3.0/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxonomy: <http://rdf.ncbi.nlm.nih.gov/pubchem/taxonomy/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?title ?paper_url ?journal ?date "PubChem" AS ?source
WHERE { 
  VALUES ?relatedMatch { {{mondo_id_list}} }
  VALUES ?ncbigene { {{ncbi_gene_id_list}} }

  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/disease> {
    ?disease skos:relatedMatch ?relatedMatch .
    #FILTER (CONTAINS(STR(?relatedMatch), "MONDO"))
  }
  
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/gene> {
    ?gene rdfs:seeAlso ?ncbigene .
    #FILTER (CONTAINS(STR(?ncbigene), "http://identifiers.org/ncbigene:"))
    ?gene rdf:type sio:SIO_010035 ;
          bao:BAO_0002870 ?md5 ;
          up:organism taxonomy:TAXID9606 .
  }
  
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/cooccurrence> {
    ?cooccurrence rdf:subject ?disease ;
                  rdf:object ?md5 ;
                  rdf:type sio:SIO_000983 . #gene-disease association
  }
  
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/reference> {
    ?ref pcvocab:discussesAsDerivedByTextMining ?md5, ?disease ;
         dcterms:title ?title ;
         dcterms:identifier ?paper_url ;
         prism:publicationName ?journal ;
         dcterms:date ?date .
    FILTER (?title != "Title Not Available")
    FILTER REGEX(STR(?paper_url), "^https://pubmed\\.ncbi\\.nlm\\.nih\\.gov/\\d+$")
    BIND(
      IF(
        REGEX(STR(?date), "^\\d{4}-\\d{2}-\\d{2}$"),
        xsd:dateTime(?date),
        IF(
          REGEX(STR(?date), "^\\d{6}$"),
          xsd:dateTime(CONCAT(SUBSTR(STR(?date), 1, 4), "-", SUBSTR(STR(?date), 5, 2), "-01")),
          xsd:dateTime("1900-01-01")
        )
      ) AS ?normalizedDate
    )
    #FILTER(?normalizedDate >= "2023-01-01T00:00:00"^^xsd:dateTime)
  }
}
ORDER BY ?ncbigene DESC (?normalizedDate)
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