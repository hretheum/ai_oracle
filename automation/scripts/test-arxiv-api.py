#!/usr/bin/env python3
"""
Test script for ArXiv API - verify connection before setting up Make.com
"""

import requests
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta

def test_arxiv_api():
    """Test ArXiv API connection and parse results"""
    
    # API endpoint
    base_url = "http://export.arxiv.org/api/query"
    
    # Parameters
    params = {
        "search_query": "cat:cs.AI OR cat:cs.LG OR cat:cs.CL",
        "start": 0,
        "max_results": 5,  # Just 5 for testing
        "sortBy": "submittedDate",
        "sortOrder": "descending"
    }
    
    print("🔍 Testing ArXiv API...")
    print(f"Query: {params['search_query']}")
    print("-" * 50)
    
    try:
        # Make request
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        
        # Parse XML
        root = ET.fromstring(response.content)
        
        # Define namespaces
        ns = {'atom': 'http://www.w3.org/2005/Atom'}
        
        # Find all entries
        entries = root.findall('atom:entry', ns)
        
        print(f"\n✅ Found {len(entries)} papers\n")
        
        # Process each entry
        for i, entry in enumerate(entries, 1):
            title = entry.find('atom:title', ns).text.strip()
            arxiv_id = entry.find('atom:id', ns).text.split('/')[-1]
            
            # Get authors
            authors = []
            for author in entry.findall('atom:author', ns):
                name = author.find('atom:name', ns).text
                authors.append(name)
            
            # Get dates
            published = entry.find('atom:published', ns).text
            pub_date = datetime.fromisoformat(published.replace('Z', '+00:00'))
            
            # Get abstract
            abstract = entry.find('atom:summary', ns).text.strip()
            abstract_preview = abstract[:100] + "..." if len(abstract) > 100 else abstract
            
            # Get PDF link
            pdf_link = None
            for link in entry.findall('atom:link', ns):
                if link.get('title') == 'pdf':
                    pdf_link = link.get('href')
                    break
            
            print(f"📄 Paper {i}:")
            print(f"   Title: {title}")
            print(f"   ID: {arxiv_id}")
            print(f"   Authors: {', '.join(authors[:3])}{' et al.' if len(authors) > 3 else ''}")
            print(f"   Published: {pub_date.strftime('%Y-%m-%d')}")
            print(f"   PDF: {pdf_link}")
            print(f"   Abstract: {abstract_preview}")
            print()
        
        # Test data structure for Make.com
        print("\n📋 Sample data structure for Make.com:")
        if entries:
            first_entry = entries[0]
            print("{")
            print(f'  "title": "{first_entry.find("atom:title", ns).text.strip()}",')
            print(f'  "arxiv_id": "{first_entry.find("atom:id", ns).text.split("/")[-1]}",')
            print(f'  "published": "{first_entry.find("atom:published", ns).text}",')
            print('  "authors": [...]')
            print("}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error connecting to ArXiv API: {e}")
    except ET.ParseError as e:
        print(f"❌ Error parsing XML response: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    test_arxiv_api()
