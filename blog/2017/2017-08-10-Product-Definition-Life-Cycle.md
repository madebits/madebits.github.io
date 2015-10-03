#Product Definition Life Cycle

2017-08-10

<!--- tags: agile management -->

An idea goes through several documented steps to become a product.

Marketings Requirements Definition (MRD)

MRD contain the vision and explains reason d’etre for one more products. What is problem that we are trying to solve and what is the solution. MRD contains the market research and a business analysis of existing and related solutions. MRD addresses costs and expected rewards of the proposed solution. One MRD may result in one or more products.

Product Requirements Definition (PRD)

PRD describes one product. PRD explains where the product fits in the current set of existing products and what high-level requirements the product is expected to fulfill and how does it looks. PRD explains the features and functions of the main components of the product. Each PRD entry captures a large body of work about the product that has a common objective. PRD can describe the product using hierarchical decomposition as a set of components, made of features, that have functions, handled by one or more use cases in SRS. In agile projects PRD items can be modeled via Epics.

System Requirements Specification (SRS)

SRS items refine use cases of PRD entries and manage details based on the actual system implementation. SRS deals with how we implement the product. One PRD feature is handled by one or more SRS entries. Dependencies to other systems may be mentioned in PRD level, but they are fully described and dealt with in SRS level. SRS items are clear enough that they can be implemented. UI mockups and other specification elements are part of SRS. In agile projects PRD items can be modeled via use Stories.

Functional Specification (FS)

FS is an optional document about how the product SRS use cases are actually implemented. One SRS entry may be handled by one or more FS items. SRS is written before implementation and FS is written after implementation. Technical Specification (TS) could be part of FS or be created as a separate document and contains details on architecture and actual code of the product. The purpose of FS is not to document the product, but to document the actual created system in details needed for using and maintaining it. FS is directly traceable to work items related to implementation code.
 

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-06-30-Low-Information-Density-User-Interfaces.md'>Low Information Density User Interfaces</a></ins>
