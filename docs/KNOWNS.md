## Known issues or bugs

- Reloading workers using an existing `etcd` cluster will still show the
  previous worker as being `NotReady` (fairly obvious).

```sh
$ kubectl get nodes
NAME                                   STATUS     AGE
637685be-625a-cd87-a119-c190d5e0e33e   Ready      57s
89bba720-3fe2-6620-f198-91db90548422   NotReady   8h
e214bdab-5d6c-c2d3-d039-dae6e3708211   Ready      58s
eebbc442-6c59-e3e3-97ac-9ffe0a610574   Ready      57s
$ kubectl delete node 89bbd720-3fe2-6620-f198-91db90548422
```
