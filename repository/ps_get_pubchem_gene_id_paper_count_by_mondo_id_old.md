# [PCF] Get GENE ID AND PAPER COUNT by MONDO ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0005093
  * example: 0007254, 0007943, 0018096, 0007477

## Endpoint
https://rdfportal.org/backend/pubchem/sparql

//https://rdfportal.org/pubchem/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) =>
  'mondo:' + mondo_id.replace(/MONDO:/gi, '').trim().replace(/[\s,]+/g, ' mondo:');
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

SELECT DISTINCT ?gene_id (COUNT(DISTINCT ?ref) AS ?count)
WHERE {
  {
    SELECT DISTINCT ?disease ?md5 WHERE {
      VALUES ?relatedMatch { {{mondo_id_list}} }
      GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/disease> {
        ?disease skos:relatedMatch ?relatedMatch .
      }
      GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/cooccurrence> {
        ?cooccurrence rdf:subject ?disease ;
                      rdf:object ?md5 ;
                      rdf:type sio:SIO_000983 .
      }
      GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/gene> {
        ?gene bao:BAO_0002870 ?md5 ;
              up:organism taxonomy:TAXID9606 ;
              rdf:type sio:SIO_010035 .
      }
    }
  }
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/reference> {
    ?ref pcvocab:discussesAsDerivedByTextMining ?disease, ?md5 ;
         dcterms:title ?title ;
         dcterms:identifier ?identifier ;
         dcterms:date ?date .
    FILTER (?title != "Title Not Available")
    FILTER REGEX(STR(?identifier), "^https://pubmed\\.ncbi\\.nlm\\.nih\\.gov/\\d+$")
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
  GRAPH <http://rdf.ncbi.nlm.nih.gov/pubchem/gene> {
    ?gene bao:BAO_0002870 ?md5 ;
          up:organism taxonomy:TAXID9606 ;
          rdf:type sio:SIO_010035 .
    ?gene rdfs:seeAlso ?gene_id .
    FILTER (CONTAINS(STR(?gene_id), "http://identifiers.org/ncbigene:"))   
  }
}
```

## Output
```javascript
({ result }) => {
  return result.results.bindings.map(data => {
    return {
      gene_id: data.gene_id.value.replace("http://identifiers.org/ncbigene:", ""),
      count: data.count.value
    };
  });
}
```