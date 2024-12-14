package com.devsecops.controller;

import com.devsecops.model.Contact;
import com.devsecops.repository.ContactRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contact")
public class ContactController {

    @Autowired
    private ContactRepository contactRepository;

    @PostMapping
    public Contact saveContact(@RequestBody Contact contact) {
        return contactRepository.save(contact);
    }

    @GetMapping("/all")
    public List<Contact> getAllContacts() {
        return (List<Contact>) contactRepository.findAll();
    }
}

