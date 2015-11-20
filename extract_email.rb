require 'rubygems'
require 'json'
require 'Time'


# Keywords to match against our security, practice topics
term1 = /crash|denial of service|access level|sizing issues|resource consumption|data loss|flood|integrity|overflow|null problem|overload|protection|leak/
term2 = /security|vulnerability|vulnerable|hole|exploit|attack|bypass|backdoor|threat|expose|breach|violate|fatal|blacklist|overrun|insecure/

ACS = /street address|credit card number|data classification|data inventory|Personally Identifiable Information (PII)|user data|privacy/
ASR = /authentication|authorization|requirement|use case|scenario|specification|confidentiality|availability|integrity|non-repudiation|user role|regulations|contractual agreements|obligations|risk assessment|FFIEC|GLBA|OCC|PCI DSS|SOX|HIPAA/ 
PTM = /threats|attackers|attacks|attack pattern|attack surface|vulnerability|exploit|misuse case|abuse case/ 
DTS = /stack|operating system|database|application server|runtime environment|language|library|component|patch|framework|sandbox|environment|network|tool|compiler|service|version/ 

Topics = [
         { :topic => "PMASA?", :keywords => /PMASA|home_page\/security/ },
         { :topic => "Security1", :keywords => term1 },
         { :topic => "Security2", :keywords => term2 },
         { :topic => "Apply Classification Scheme", :keywords => ACS },
         { :topic => 'Apply Security Requirements', :keywords => ASR },
	 { :topic => 'Perform Threat Modeling', :keywords => PTM },
	 { :topic => 'Document Technical Stack', :keywords => DTS },
{ :topic => 'Apply Secure Coding Standards', :keywords =>	/avoid|banned|buffer overflow|checklist|code|code review|code review checklist|coding technique|commit checklist|dependency|design pattern|do not use|enforce function|firewall|grant|input validation|integer overflow|logging|memory allocation|methodology|policy|port|security features|security principle|session|software quality|source code|standard|string concatenation|string handling function|SQL Injection|unsafe functions|validate|XML parser/ },
{ :topic => 'Apply Security Tooling', :keywords =>	/automate|automated|automating|code analysis|coverage analysis|dynamic analysis|false positive|fuzz test|fuzzer|fuzzing|malicious code detection|scanner|static analysis|tool/ },
{ :topic => 'Perform Security Testing', :keywords =>	/boundary value|boundary condition|edge case|entry point|input validation|interface|output validation|replay testing|security tests|test|tests|test plan|test suite|validate input|validation testing|regression test/ },
{ :topic => 'Perform Penetration Testing', :keywords => 	/penetration/ },
{ :topic => 'Perform Security Review', :keywords =>	/architecture analysis|attack surface|bug bar|code review|denial of service|design review|elevation of privilege|information disclosure|quality gate|release gate|repudiation|review|security design review|security risk assessment|spoofing|tampering|STRIDE/ },
{ :topic => 'Publish Operations Guide', :keywords =>	/administrator|alert|configuration|deployment|error message|guidance|installation guide|misuse case|operational security guide|operator|security documentation|user|warning/ },
{ :topic => 'Track Vulnerabilities', :keywords =>	/bug|bug bounty|bug database|bug tracker|defect|defect tracking|incident|incident response|severity|top bug list|vulnerability|vulnerability tracking/ },
{ :topic => 'Improve Development Process', :keywords =>	/architecture analysis|code review|design review|development phase,gate|root cause analysis|software development lifecycle|software process/ },
{ :topic => 'Provide Training', :keywords =>	/awareness program|class|conference|course|curriculum|education|hiring|refresher|mentor|new developer|new hire|on boarding|teacher|training/ } 
         ]
 
# print line with project, date, source, creator, issue #, reporter, keywords, topic
def write_data_row(d_id,project_month,d_created_at,d_reportedBy,d_owner,project="phpMyAdmin",topic="",source="Bug Tracker",count,filename,d_content)

  print project_month, ", ", d_created_at, ", ", project, ", ", topic, ", ",  source,  ", ", d_id, ", ",
  d_reportedBy, ", ", d_owner, ", " , "\n" # d_content, ", ", count, ", ", filename
end

pathname = ARGV[0]
project = ARGV[1]
print "ProjectMonth,EventDate,Project,Practice,Source,DocId,creator,assignee,\n"
Dir.foreach(pathname) do |filename|
next if filename == '.' or filename == '..'
count = 0
d_reportedBy = 'pat'
d_owner = d_id = d_created_at = project_month = ""
d_content = "Content: "

File.open(pathname + '/' + filename).each do |l| 
  if ! l.valid_encoding?
    l = l.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  end
  if match = l[/^From (.*)$/,1]
    if count > 0
      Topics.map { |t| 
        if d_content.scan(t[:keywords]).length > 0
          write_data_row(d_id,project_month,d_created_at,d_reportedBy,d_owner,project=project,t[:topic],source="email",count,filename,d_content)
        end
      }
    end
    count = count + 1
    d_owner = d_id = d_created_at = project_month = ""
    d_content = "Content: "
  end
    if match = l[/^From: (.*)/, 1]
        d_owner = match
        # puts "d_owner: ", d_owner
    end
    if match  = l[/^Message-ID: (.*)/, 1]
      d_id = match
      # puts "d_id: ", d_id
    end
    if match  = l[/^Date: (.*)/, 1]
      d_created_at = match
      begin
        d_created_at = (Date.parse d_created_at).strftime("%Y-%m-%d")
        project_month = ((Date.parse d_created_at) >> 1).strftime("%Y-%m-01")
      rescue ArgumentError
        d_created_at = project_month
      end
      # puts "project_month: ", d_created_at
    end
  d_content << l
# print count, ", ", d_content.length, ", " , "\n"
end
end
